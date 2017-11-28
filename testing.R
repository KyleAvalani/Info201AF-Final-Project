library(spotifyr)
library(httr)
library(jsonlite)

source("./api-keys.R")

encoded.string <- base64_enc(paste0(client.id,":",client.secret))
updated.string <-paste0("Authorization: Basic ",encoded.string)

#set_credentials(client_id=client.id,client_secret=client.secret,client_redirect_uri = "www.kyleavalani.com")

query.params <- list(grant_type='client_credentials')
response <- POST("https://accounts.spotify.com/api/token", query = query.params,
                 add_headers(updated.string))

#response <- POST(url = "https://accounts.spotify.com/api/token",
                 # accept_json(),
                 # authenticate(Sys.getenv('9318d80992224d8faebabb17901502d8'), Sys.getenv('e3fff7143d0946048ade1f85b4d83e6e')),
                 # body = list(grant_type='client_credentials'),
                 # encode = 'form')


body <- content(response, "text")  # extract the body JSON
parsed.data <- fromJSON(body)  # convert the JSON string to a list

client_tokens <- get_tokens()
#access_token <- "NgCXRJ...MzYjw"

response = POST(
  'https://accounts.spotify.com/api/token',
  accept_json(),
  authenticate(client.id, client.secret),
  body = list(grant_type = 'client_credentials'),
  encode = 'form',
  verbose()
)

token = content(response)$access_token
authorization.header = paste0("Bearer ", token)

test <- GET("https://api.spotify.com/v1/artists/0OdUWJ0sBjDrqHygGUXeCF", add_headers(authorization = authorization.header))
test.body <- content(test, "text")  # extract the body JSON
test.parsed.data <- fromJSON(test.body)  # convert the JSON string to a list








