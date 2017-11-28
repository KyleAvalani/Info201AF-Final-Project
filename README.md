# Info201AF-Final-Project

Potential plan (temporarily written here for our sake):

Artist Top Tracks in Specified Country Route:

1. Have the user enter an artist's name and then use the search endpoint to find that artist's Spotify ID, which is needed for any requests for that specific artist.
  -(https://developer.spotify.com/web-api/search-item/)
2. Have the user then click on a country on a map (or maybe just enter a country, it doesn't matter) and then correlate that country with it's ISO 3166-1 alpha-2 code and save that variable for future use in requests.
  -(https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)
3. Use the artist ID and country code to search for the artist's top tracks and then display them (perhaps just in a chart?) by popularity (an integer algorithmically calculated by Spotify and returned to us).
  -(https://developer.spotify.com/web-api/get-artists-top-tracks/)

Country Top Charts Route:

Using the Global Top 50 charts (there's a separate playlist for each country that's updated daily by Spotify themselves to include the top tracks of that country) we could simply display a world map and then when the user clicks on a country they could see the chart and maybe we could generate some statistics and data visualizations based off of the chart. For example, there's a lot of cool info we can get if we request an Audio Analysis of a track, like a song's "danceability" rating and such.

1. Have a user click on a country on a map, having that country button correlate with just the country's name, and then throw that into a paste0 string to build the name of the Top 50 playlist for that country (ex: Chile Top 50). Use that string as the parameter in a search function for type playlist and just select the one that's by Spotify.
  -(https://developer.spotify.com/web-api/search-item/)
2. Display the returned tracks in some way (possibly a nice chart?) and then make a request for an audio analysis on all the tracks and grab some cool data and make some cool data visualizations or analysis for the tracks.
  -(https://developer.spotify.com/web-api/get-audio-analysis/)
