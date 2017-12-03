library(spotifyr)
library(httr)
library(jsonlite)
library(dplyr)

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

#Uses retrieved playlist ID to create a dataframe of that playlist's important information (tracks, track ids, etc)
playlist.id <- "37i9dQZEVXbLRQDuF5jeBp"
playlist.tracks.base.uri <- paste0("https://api.spotify.com/v1/users/spotifycharts/playlists/", playlist.id)
playlist.tracks <- GET(playlist.tracks.base.uri, add_headers(authorization = authorization.header))
playlist.tracks.body <- content(playlist.tracks, "text")
playlist.tracks.parsed.data <- fromJSON(playlist.tracks.body)
clean.playlist.tracks <- data.frame(t(sapply(playlist.tracks.parsed.data,c)))
clean.playlist.tracks <- flatten(clean.playlist.tracks)
specific.tracks <- clean.playlist.tracks$tracks$tracks$items$track
formatted.playlist.tracks <- select(specific.tracks, id, name, artists)

#Uses dataframe of playlist's information to request information on each track's audio features, storing that information
comma.separated.ids <- paste(formatted.playlist.tracks$id, collapse = ",")
query.parameters <- list(ids = comma.separated.ids)
audio.features.base.uri <- "https://api.spotify.com/v1/audio-features"
info.on.track <- GET(audio.features.base.uri, query = query.parameters, add_headers(authorization = authorization.header))
info.on.track.body <- content(info.on.track, "text")
info.on.track.parsed.data <- data.frame(fromJSON(info.on.track.body)) 
