library(httr)
library(jsonlite)
library(dplyr)
library(stringr)

#Retrieves api-keys
source("./api-keys.R")

#Encodes the authentication string in Base64, which is required to make requests from Spotify's API.
encoded.string <- base64_enc(paste0(client.id,":",client.secret))
updated.string <-paste0("Authorization: Basic ",encoded.string)

#Makes the request to Spotify for the API token
response <- POST(
  'https://accounts.spotify.com/api/token',
  accept_json(),
  authenticate(client.id, client.secret),
  body = list(grant_type = 'client_credentials'),
  encode = 'form',
  verbose()
)

#Extracts and stores the API token and then creates the authorization header
token <- content(response)$access_token
authorization.header <- paste0("Bearer ", token)

#Get playlist's ID from the name of it's country.
country.name <- "United States" #Temporary value, REMOVE LATER
GetPlaylistID <- function(country.name){
  source("country-playlist-data.R")
  playlist.id <- filter(country.info.df, countries == country.name)
  return(playlist.id) #uncomment this when working within this file
  #return(playlist.id$country.id) #comment this when working within this file
}
playlist.id <- GetPlaylistID(country.name)

#Uses retrieved playlist ID to create a dataframe of that playlist's important information (tracks, track ids, etc)
GetPlaylistTracks <- function(playlist.id){
  playlist.tracks.base.uri <- paste0("https://api.spotify.com/v1/users/spotifycharts/playlists/", playlist.id)
  playlist.tracks <- GET(playlist.tracks.base.uri, add_headers(authorization = authorization.header))
  playlist.tracks.body <- content(playlist.tracks, "text")
  playlist.tracks.parsed.data <- fromJSON(playlist.tracks.body)
  clean.playlist.tracks <- data.frame(t(sapply(playlist.tracks.parsed.data,c)))
  specific.tracks <- clean.playlist.tracks$tracks$tracks$items$track
  formatted.playlist.tracks <- select(specific.tracks, id, name, artists)
  artist.names <- data.frame(t(sapply(specific.tracks$artists,c)))$name
  artist.names <- lapply(artist.names, paste, collapse = ", ")
  formatted.playlist.tracks$artists <- artist.names
  final.playlist.formatting <- data.frame(data.frame(1:50), formatted.playlist.tracks)
  colnames(final.playlist.formatting) <- c("Ranking", "id", "Title", "Artists")
  return(final.playlist.formatting)
}
formatted.playlist.tracks <- GetPlaylistTracks(playlist.id)

#Uses dataframe of playlist's information to request information on each track's audio features, storing that information
GetTrackAudioFeatures <- function(formatted.playlist.tracks){  
  comma.separated.ids <- paste(formatted.playlist.tracks$id, collapse = ",")
  query.parameters <- list(ids = comma.separated.ids)
  audio.features.base.uri <- "https://api.spotify.com/v1/audio-features"
  info.on.track <- GET(audio.features.base.uri, query = query.parameters, add_headers(authorization = authorization.header))
  info.on.track.body <- content(info.on.track, "text")
  info.on.track.parsed.data <- data.frame(fromJSON(info.on.track.body)) 
  colnames(info.on.track.parsed.data) <- gsub("audio_features.","",colnames(info.on.track.parsed.data))
  info.on.track.parsed.data <- select(info.on.track.parsed.data, danceability, energy, key, loudness, mode, speechiness,
                                      acousticness, instrumentalness, liveness, valence, tempo, duration_ms)
  return(info.on.track.parsed.data)
}
info.on.track.parsed.data <- GetTrackAudioFeatures(formatted.playlist.tracks)

# Audio Analysis for each feature 

audio.anaylsis.averages <- summarise(info.on.track.parsed.data, dance.avg = mean(info.on.track.parsed.data$danceability),  
     energy.avg = mean(info.on.track.parsed.data$energy),
     key.avg = mean(info.on.track.parsed.data$key), loudness.avg = mean(info.on.track.parsed.data$loudness), 
     mode.avg = mean(info.on.track.parsed.data$mode),speechiness.avg = mean(info.on.track.parsed.data$speechiness),
     acousticness.avg = mean(info.on.track.parsed.data$acousticness), instrumentalness.avg = mean(info.on.track.parsed.data$instrumentalness),
     liveness.avg = mean(info.on.track.parsed.data$liveness), valence.avg = mean(info.on.track.parsed.data$valence), 
     tempo.avg = mean(info.on.track.parsed.data$tempo), duration.avg = mean(info.on.track.parsed.data$duration_ms))



# Sad attempt at a function to use with lapply

source('country-playlist-data.R')
countries.and.features <- country.info.df
countries.and.features <- data_frame()

AverageFeature <- function(country) {
  df <- GetTrackAudioFeatures(GetPlaylistTracks(GetPlaylistID(country)))
  feature.averages <- data_frame()
  feature.averages$countries <- country
  feature.averages <- summarise(df, 
    dance.avg = mean(df$danceability),  
    energy.avg = mean(df$energy),
    key.avg = mean(df$key), loudness.avg = mean(df$loudness), 
    mode.avg = mean(df$mode),speechiness.avg = mean(df$speechiness),
    acousticness.avg = mean(df$acousticness), instrumentalness.avg = mean(df$instrumentalness),
    liveness.avg = mean(df$liveness), valence.avg = mean(df$valence), 
    tempo.avg = mean(df$tempo), duration.avg = mean(df$duration_ms)
  )
  countries.and.features <- (feature.averages)
  return(countries.and.features)
}

a <- AverageFeature('United States')

# Need better method of adding rows..
countries.and.features <- full_join(countries.and.features, AverageFeature('United States'))

# Doesn't Work
countries.and.features <- full_join(countries.and.features, AverageFeature('Uruguay'))
  # Not yet working... because of function pre-set for United States?
#lapply(country.info.df[,countries], AverageFeature(country.info.df$countries))
