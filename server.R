#server.R
library(shiny)
library(dplyr)
library(ggplot2)
library(shinythemes)
library(stringr)

source("country-playlist-data.R")

# Light grey boundaries
l <- list(color = toRGB("grey"), width = 0.5)

# Specify map projection/options
g <- list(
  showframe = FALSE,
  showcoastlines = TRUE,
  projection = list(type = 'Mercator')
)

# Start shinyServer
shinyServer(function(input, output) { 
  output$map <- renderPlotly({ 
    
    temp.data.frame <- select(big.data.frame, input$mapvar, countries, country.code)
    colnames(temp.data.frame) <- c("specified.audio.feature","countries","country.code")
    
    p <- plot_geo(temp.data.frame) %>%
      add_trace(
        z = ~specified.audio.feature, colors = 'Greens',
        text = ~countries, locations = ~country.code, marker = list(line = l)
      ) %>%
      colorbar(title = input$mapvar) %>%
      layout(
        title = 'Average Audio Features',
        geo = g
      )
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
    plot_ly(data = playlist.tracks.audio.features, x = playlist.tracks.audio.features[,1], type = 'scatter',
            color = playlist.tracks.audio.features[,1]) %>% 
            layout(xaxis = list(title = str_to_title(input$feature)), yaxis = list(title = "Song Ranking"),
                   title = paste0(str_to_title(input$feature)," vs. Song Ranking"))
  })
})

