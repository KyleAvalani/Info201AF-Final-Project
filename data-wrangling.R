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
country.name <- "United States" #Initialize variable with temp value
GetPlaylistID <- function(country.name){
  source("country-playlist-data.R")
  playlist.id <- filter(country.info.df, countries == country.name)
  return(playlist.id$country.id) #comment this when working within this file
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

playlist.id <- GetPlaylistID("United States")
playlist.tracks.base.uri <- paste0("https://api.spotify.com/v1/users/spotifycharts/playlists/", playlist.id)
playlist.tracks <- GET(playlist.tracks.base.uri, add_headers(authorization = authorization.header))
playlist.tracks.body <- content(playlist.tracks, "text")
playlist.tracks.parsed.data <- fromJSON(playlist.tracks.body)
clean.playlist.tracks <- data.frame(t(sapply(playlist.tracks.parsed.data,c)))
specific.tracks <- clean.playlist.tracks$tracks$tracks$items$track

#Uses dataframe of playlist's information to request information on each track's audio features, storing that information
GetTrackAudioFeatures <- function(formatted.playlist.tracks){  
  comma.separated.ids <- paste(formatted.playlist.tracks$id, collapse = ",")
  query.parameters <- list(ids = comma.separated.ids)
  audio.features.base.uri <- "https://api.spotify.com/v1/audio-features"
  info.on.track <- GET(audio.features.base.uri, query = query.parameters, add_headers(authorization = authorization.header))
  info.on.track.body <- content(info.on.track, "text")
  info.on.track.parsed.data <- data.frame(fromJSON(info.on.track.body)) 
  colnames(info.on.track.parsed.data) <- str_to_title(gsub("audio_features.","",colnames(info.on.track.parsed.data)))
  info.on.track.parsed.data <- select(info.on.track.parsed.data, Danceability, Energy, Key, Loudness, Mode, Speechiness,
                                      Acousticness, Instrumentalness, Liveness, Valence, Tempo, Duration_ms)
  return(info.on.track.parsed.data)
}
info.on.track.parsed.data <- GetTrackAudioFeatures(formatted.playlist.tracks)

# Audio Analysis for each feature 
source('country-playlist-data.R')

all.country.averages <- data.frame()

AverageFeature <- function(country) {
  df <- GetTrackAudioFeatures(GetPlaylistTracks(GetPlaylistID(country)))
  feature.averages <- summarise(df, 
    dance.avg = mean(df$Danceability, na.rm = TRUE),  
    energy.avg = mean(df$Energy, na.rm = TRUE),
    key.avg = mean(df$Key, na.rm = TRUE), loudness.avg = mean(df$Loudness, na.rm = TRUE), 
    mode.avg = mean(df$Mode, na.rm = TRUE),speechiness.avg = mean(df$Speechiness, na.rm = TRUE),
    acousticness.avg = mean(df$Acousticness, na.rm = TRUE), instrumentalness.avg = mean(df$Instrumentalness, na.rm = TRUE),
    liveness.avg = mean(df$Liveness, na.rm = TRUE), valence.avg = mean(df$Valence, na.rm = TRUE), 
    tempo.avg = mean(df$Tempo, na.rm = TRUE), duration.avg = mean(df$Duration_ms, na.rm = TRUE)
  )
  feature.averages$countries = country
  all.country.averages <- rbind(all.country.averages, feature.averages)
  return(all.country.averages)
}

big.data.frame <- rbind(AverageFeature('Argentina'), AverageFeature('Australia'), AverageFeature('Austria'), AverageFeature('Belgium'), AverageFeature('Bolivia'), AverageFeature('Brazil'), AverageFeature('Canada'),
                        AverageFeature('Chile'), AverageFeature('Colombia'), AverageFeature('Costa Rica'), AverageFeature('Czech Republic'), AverageFeature('Denmark'), AverageFeature('Dominican Republic'),
                        AverageFeature('Ecuador'), AverageFeature('El Salvador'), AverageFeature('Estonia'), AverageFeature('Finland'), AverageFeature('France'), AverageFeature('Germany'), AverageFeature('Greece'),
                        AverageFeature('Guatemala'), AverageFeature('Honduras'), AverageFeature('Hong Kong'), AverageFeature('Hungary'), AverageFeature('Iceland'), AverageFeature('Indonesia'), AverageFeature('Ireland'),
                        AverageFeature('Italy'), AverageFeature('Japan'), AverageFeature('Latvia'), AverageFeature('Lithuania'), AverageFeature('Malaysia'), AverageFeature('Mexico'), AverageFeature('Netherlands'), AverageFeature('New Zealand'),
                        AverageFeature('Norway'), AverageFeature('Panama'), AverageFeature('Paraguay'), AverageFeature('Peru'), AverageFeature('Philippines'), AverageFeature('Poland'), AverageFeature('Portugal'),
                        AverageFeature('Singapore'), AverageFeature('Slovakia'), AverageFeature('Spain'), AverageFeature('Sweden'), AverageFeature('Switzerland'), AverageFeature('Taiwan'), AverageFeature('Thailand'),
                        AverageFeature('Turkey'), AverageFeature('United Kingdom'), AverageFeature('United States'), AverageFeature('Uruguay'))
big.data.frame <- data.frame(big.data.frame, country.code)
