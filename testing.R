library(spotifyr)
library(httr)
library(jsonlite)

source("./api-keys.R")

encoded.string <- base64_enc(paste0(client.id,":",client.secret))
updated.string <-paste0("Authorization: Basic ",encoded.string)

#query.params <- list(grant_type='client_credentials')
#response <- POST("https://accounts.spotify.com/api/token", query = query.params,
#                 add_headers(updated.string))

#response <- POST(url = "https://accounts.spotify.com/api/token",
                 # accept_json(),
                 # authenticate(Sys.getenv('9318d80992224d8faebabb17901502d8'), Sys.getenv('e3fff7143d0946048ade1f85b4d83e6e')),
                 # body = list(grant_type='client_credentials'),
                 # encode = 'form')

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
a <- data.frame(lapply(test.parsed.data,c))


