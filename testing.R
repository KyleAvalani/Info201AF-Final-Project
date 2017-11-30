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

##Nonfunctioning attempts to tidy up the data into a dataframe
x <- data.frame(t(sapply(test.parsed.data,c)))
x <- flatten(x)
df <- data.frame(matrix(unlist(test.parsed.data), byrow=T),stringsAsFactors=FALSE)