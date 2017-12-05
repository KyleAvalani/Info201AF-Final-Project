#server.R
library(shiny)
library(dplyr)
library(ggplot2)

# Place holder data
df <- read.csv('https://raw.githubusercontent.com/plotly/datasets/master/2014_world_gdp_with_codes.csv')

source("country-playlist-data.R")

# light grey boundaries
l <- list(color = toRGB("grey"), width = 0.5)

# specify map projection/options
g <- list(
  showframe = FALSE,
  showcoastlines = FALSE,
  projection = list(type = 'Mercator')
)

# Place holder map
p <- plot_geo(df) %>%
  add_trace(
    z = ~GDP..BILLIONS., color = ~GDP..BILLIONS., colors = 'Blues',
    text = ~COUNTRY, locations = ~CODE, marker = list(line = l)
  ) %>%
  colorbar(title = 'GDP Billions US$', tickprefix = '$') %>%
  layout(
    title = 'Top of the charts ',
    geo = g
  )


# Start shinyServer
shinyServer(function(input, output) { 
  output$map <- renderPlotly({ 
    return(p)
  })
  output$table <- renderTable({
    playlist.tracks <- GetPlaylistTracks(GetPlaylistID(input$country)) %>% 
      select(Ranking, Title, Artists)
    return(playlist.tracks)
  })
  output$audio.analysis <- renderPlotly({
    playlist.tracks.audio.features <- GetPlaylistTracks(GetPlaylistID(input$country2)) %>% 
      GetTrackAudioFeatures() %>% 
      select(input$feature)
    plot_ly(data = playlist.tracks.audio.features, x = playlist.tracks.audio.features[,1], type = 'histogram',
            color = playlist.tracks.audio.features[,1]) %>% 
            layout(xaxis = list(title = input$feature))
  })
})