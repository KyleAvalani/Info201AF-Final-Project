library(spotifyr)
library(httr)
library(jsonlite)
library(dplyr)

source("./api-keys.R")

#This encodes the authentication string in Base64, which is required to make requests from Spotify's API.
encoded.string <- base64_enc(paste0(client.id,":",client.secret))
updated.string <-paste0("Authorization: Basic ",encoded.string)

response <- POST(
  'https://accounts.spotify.com/api/token',
  accept_json(),
  authenticate(client.id, client.secret),
  body = list(grant_type = 'client_credentials'),
  encode = 'form',
  verbose()
)

token <- content(response)$access_token
authorization.header <- paste0("Bearer ", token)

test <- GET("https://api.spotify.com/v1/artists/0OdUWJ0sBjDrqHygGUXeCF", add_headers(authorization = authorization.header))
test.body <- content(test, "text")  # extract the body JSON
test.parsed.data <- fromJSON(test.body)  # convert the JSON string to a list

#Attempt at getting search endpoint to work
query.params <- list(q= "canada+top",  type = "playlist")
search <- GET("https://api.spotify.com/v1/search", add_headers(authorization = authorization.header), query = query.params)
search.body <- content(search, "text")
search.parsed.data <- fromJSON(search.body)
a <- data.frame(t(sapply(search.parsed.data,c)))
a <- flatten(a)
b <- a$items
d <- data.frame(t(sapply(b,c)))
d <- flatten(d)
data.names <- d$name

data.owner <- d$owner$owner$id
data.tracks <- d$tracks$tracks

check.info <- data.frame(data.names, data.owner, data.tracks)

#Attempt at looking at Top 50 playlist with spotify as the user
#query.params <- list(q= "canada+top+50",  type = "playlist")
search.playlist <- GET("https://api.spotify.com/v1/users/spotify/playlists/37i9dQZF1DX82re5NxbwyO", add_headers(authorization = authorization.header))
search.playlist.body <- content(search.playlist, "text")
search.playlist.parsed.data <- fromJSON(search.playlist.body)
playlist.country <- data.frame(t(sapply(search.playlist.parsed.data,c)))
playlist.country <- flatten(playlist.country)
q <- playlist.country$tracks
w <- data.frame(t(sapply(q,c)))
names <- w$items
names.df <- data.frame(t(sapply(names,c)))
tracks <- names.df$track$track$name
song.names <- data.frame(t(sapply(tracks,c)))

#CHECKING SPECFIC PLAYLIST
search.playlist.US <- GET("https://api.spotify.com/v1/users/spotifycharts/playlists/37i9dQZEVXbLRQDuF5jeBp/tracks", add_headers(authorization = authorization.header))
search.playlist.body.US <- content(search.playlist.US, "text")
search.playlist.parsed.data.US <- fromJSON(search.playlist.body.US)
playlist.US <- data.frame(t(sapply(search.playlist.parsed.data.US,c)))
US.info <- playlist.US$items

##IMPORTANT STUFF BELOW

playlist.tracks <- GET("https://api.spotify.com/v1/users/spotify/playlists/37i9dQZF1DX82re5NxbwyO", add_headers(authorization = authorization.header))
playlist.tracks.body <- content(playlist.tracks, "text")
playlist.tracks.parsed.data <- fromJSON(playlist.tracks.body)
clean.playlist.tracks <- data.frame(t(sapply(playlist.tracks.parsed.data,c)))
clean.playlist.tracks <- flatten(clean.playlist.tracks)
specific.tracks <- clean.playlist.tracks$tracks$tracks$items$track

formatted.playlist.tracks <- select(specific.tracks, id, name, artists)


info.on.track <- GET("https://api.spotify.com/v1/audio-features/06AKEBrKUckW0KREUWRnvT", add_headers(authorization = authorization.header))
info.on.track.body <- content(info.on.track, "text")
info.on.track.parsed.data <- fromJSON(info.on.track.body) 



##IMPORTANT STUFF ^^^^

#Formatting search
z <- data.frame(t(sapply(search.parsed.data,c)))


##Nonfunctioning attempts to tidy up the data into a dataframe
x <- data.frame(t(sapply(test.parsed.data,c)))
x <- flatten(x)
followers <- x$followers$followers[2]
images <- x$images$images
genres <- x$genres

