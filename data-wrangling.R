library(httr)
library(jsonlite)
library(dplyr)

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
  return(playlist.id$country.id)
}
playlist.id <- GetPlaylistID(country.name)$country.id

#Uses retrieved playlist ID to create a dataframe of that playlist's important information (tracks, track ids, etc)
GetPlaylistTracks <- function(playlist.id){
  playlist.tracks.base.uri <- paste0("https://api.spotify.com/v1/users/spotifycharts/playlists/", playlist.id)
  playlist.tracks <- GET(playlist.tracks.base.uri, add_headers(authorization = authorization.header))
  playlist.tracks.body <- content(playlist.tracks, "text")
  playlist.tracks.parsed.data <- fromJSON(playlist.tracks.body)
  clean.playlist.tracks <- data.frame(t(sapply(playlist.tracks.parsed.data,c)))
  clean.playlist.tracks <- flatten(clean.playlist.tracks)
  specific.tracks <- clean.playlist.tracks$tracks$tracks$items$track
  formatted.playlist.tracks <- select(specific.tracks, id, name, artists)
  artist.names <- data.frame(t(sapply(specific.tracks$artists,c)))$name
  formatted.playlist.tracks$artists <- artist.names
  return(formatted.playlist.tracks)
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
  return(info.on.track.parsed.data)
}
info.on.track.parsed.data <- GetTrackAudioFeatures(formatted.playlist.tracks)