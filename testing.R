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
US.tracks.df <- data.frame(t(sapply(US.info,c)))
data <- US.tracks.df$track
US.song.names <- data.frame(t(sapply(data,c)))
US.ID <- US.song.names$id
US.name <- US.song.names$name
US.artist <- US.song.names$artists$artists
US.artist.names <- data.frame(t(sapply(US.artist,c)))
US.artist.names <- flatten(US.artist.names)
US.real.artist.names <- US.artist.names$name
US.real.artist.names <- flatten(US.real.artist.names)
US.names.artist <- data.frame(t(sapply(US.real.artist.names,c)))
US.names.artist <- flatten(US.names.artist)
US.artists <- as.data.frame(t(US.names.artist))


US.albums <- US.song.names$album$album
US.real.albums <- US.albums$
US.top.50.df <- data.frame(US.ID, US.name, US.artists)
names(US.top.50.df)[names(US.top.50.df) == 'V1'] <- 'artists'

#Attempt to find IDs for all 53 countires featured in spot top 50
countries <- c("Argentina", "Australia", "Austria", "Belgium", "Bolivia",
               "Brazil", "Canada", "Chile", "Colombia", "Costa Rica",
               "Czech Republic", "Denmark", "Dominican Repbulic", "Ecuador", "El Salvador",
               "Estonia", "Finland", "France", "Germany", "Greece",
               "Guatemala", "Honduras", "Hong Kong", "Hungary", "Iceland",
               "Indonesia", "Ireland", "Italy", "Japan", "Latvia",
               "Lithuania", "Malaysia", "Mexico", "Netherlands", "New Zealand",
               "Norway", "Panama", "Paraguay", "Peru", "Philippines",
               "Poland", "Portugal", "Singapore", "Slovakia", "Spain",
               "Sweden", "Switzerland", "Taiwan", "Thailand", "Turkey",
               "United Kingdom", "United States", "Uruguay")
country.id <- c("37i9dQZEVXbMMy2roB9myp", "37i9dQZEVXbJPcfkRz0wJ0", "37i9dQZEVXbKNHh6NIXu36", "37i9dQZEVXbJNSeeHswcKB", "37i9dQZEVXbJqfMFK4d691",
                "37i9dQZEVXbMXbN3EUUhlg", "37i9dQZEVXbKj23U1GF4IR", "37i9dQZEVXbL0GavIqMTeb", "37i9dQZEVXbOa2lmxNORXQ", "37i9dQZEVXbMZAjGMynsQX",
                "37i9dQZEVXbIP3c3fqVrJY", "37i9dQZEVXbL3J0k32lWnN", "37i9dQZEVXbKAbrMR8uuf7", "37i9dQZEVXbJlM6nvL1nD1", "37i9dQZEVXbLxoIml4MYkT",
                "37i9dQZEVXbLesry2Qw2xS", "37i9dQZEVXbMxcczTSoGwZ", "37i9dQZEVXbIPWwFssbupI", "37i9dQZEVXbJiZcmkrIHGU", "37i9dQZEVXbJqdarpmTJDL",
                "37i9dQZEVXbLy5tBFyQvd4", "37i9dQZEVXbJp9wcIM9Eo5", "37i9dQZEVXbLwpL8TjsxOG", "37i9dQZEVXbNHwMxAkvmF8", "37i9dQZEVXbKMzVsSGQ49S",
                "37i9dQZEVXbObFQZ3JLcXt", "37i9dQZEVXbKM896FDX8L1", "37i9dQZEVXbIQnj7RRhdSX", "37i9dQZEVXbKXQ4mDTEBXq", "37i9dQZEVXbJWuzDrTxbKS",
                "37i9dQZEVXbMx56Rdq5lwc", "37i9dQZEVXbJlfUljuZExa", "37i9dQZEVXbO3qyFxbkOE1", "37i9dQZEVXbKCF6dqVpDkS", "37i9dQZEVXbM8SIrkERIYl",
                "37i9dQZEVXbJvfa0Yxg7E7", "37i9dQZEVXbKypXHVwk1f0", "37i9dQZEVXbNOUPGj7tW6T", "37i9dQZEVXbJfdy5b0KP7W", "37i9dQZEVXbNBz9cRCSFkY",
                "37i9dQZEVXbN6itCcaL3Tt", "37i9dQZEVXbKyJS56d1pgi", "37i9dQZEVXbK4gjvS1FjPY", "37i9dQZEVXbKIVTPX9a2Sb", "37i9dQZEVXbNFJfN1Vw8d9",
                "37i9dQZEVXbLoATJ81JYXz", "37i9dQZEVXbJiyhoAPEfMK", "37i9dQZEVXbMnZEatlMSiu", "37i9dQZEVXbMnz8KIWsvf9", "37i9dQZEVXbIVYVBNw9D5K",
                "37i9dQZEVXbLnolsZ8PSNw", "37i9dQZEVXbLRQDuF5jeBp", "37i9dQZEVXbMJJi3wgRbAy")
country.info.df <- data.frame(countries, country.id)


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

