#Load necessary libraries
library(shiny)
library(dplyr)
library(ggplot2)
library(shinythemes)
library(stringr)

source("country-playlist-data.R")

# Light grey boundaries for use in chloropleth map
l <- list(color = toRGB("grey"), width = 0.5)

# Specify map projection/options for chloropleth map
g <- list(
  showframe = FALSE,
  showcoastlines = TRUE,
  projection = list(type = 'Mercator')
)

# Start shinyServer
shinyServer(function(input, output) { 
  output$map <- renderPlotly({ #Chloropleth Map
    
    map.audio.features.data <- select(big.data.frame, input$mapvar, countries, country.code)
    colnames(map.audio.features.data) <- c("specified.audio.feature","countries","country.code")
    
    p <- plot_geo(map.audio.features.data) %>%
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
  output$table <- renderTable({ #Playlist Summary
    playlist.tracks <- GetPlaylistTracks(GetPlaylistID(input$country)) %>% 
      select(Ranking, Title, Artists)
    return(playlist.tracks)
  })
  output$audio.analysis <- renderPlotly({ #Playlist Breakdown
    playlist.tracks.audio.features <- GetPlaylistTracks(GetPlaylistID(input$country2)) %>% 
      GetTrackAudioFeatures() %>% 
      select(input$feature)
    plot_ly(data = playlist.tracks.audio.features, x = playlist.tracks.audio.features[,1], type = 'scatter',
            color = playlist.tracks.audio.features[,1]) %>% 
            layout(xaxis = list(title = str_to_title(input$feature)), yaxis = list(title = "Song Ranking"),
                   title = paste0(str_to_title(input$feature)," vs. Song Ranking"))
  })
})

