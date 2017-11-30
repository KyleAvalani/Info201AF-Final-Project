library(spotifyr)
library(httr)
library(jsonlite)

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
query.params <- list(artist = "Migos", type = "artist")
search <- GET("https://api.spotify.com/v1/search", add_headers(authorization = authorization.header), query = query.params)
search.body <- content(search, "text")
search.parsed.data <- fromJSON(search.body)

#Formatting search
z <- data.frame(t(sapply(search.parsed.data,c)))


##Nonfunctioning attempts to tidy up the data into a dataframe
x <- data.frame(t(sapply(test.parsed.data,c)))
x <- flatten(x)
followers <- x$followers$followers[2]
images <- x$images$images
genres <- x$genres