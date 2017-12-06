# ui.R
library(shiny)
library(plotly)
library(shinythemes)

source("country-playlist-data.R")
source("data-wrangling.R")

shinyUI(navbarPage('Music Around the Globe', theme = shinytheme("cyborg"),
    # Create a tab panel for map
    tabPanel('Map',
            titlePanel('Music by Country'),
            # Create sidebar layout
            sidebarLayout(
              
              # Side panel for controls
              sidebarPanel(
                
                # Input to select variable to map
                # Changes hover info
                selectInput('mapvar', label = 'Variable to Map', choices = list("Average Danceability" = 'danceability', 'Average Energy' = 'energy', 'Average Key' = 'key',
                                                                                'Average Loudness' = 'loudness', 'Average Mode' = 'mode', 'Average Speechiness' = 'speechiness',
                                                                                'Average Acousticness' = 'acousticness', 'Average Instrumentalness' = 'instrumentalness',
                                                                                'Average Liveness' = 'liveness', 'Average Valence' = 'valence', 'Average Tempo' = 'tempo',
                                                                                'Average Duration' = 'duration'))
              ),
              
              # Main panel: display plotly map
              mainPanel(
                plotlyOutput('map')
              )
            )
    ), 
    
    # Create a tabPanel to show your scatter plot
    tabPanel('Playlist Summary',
            # Add a titlePanel to tab
            titlePanel('Top Fifty Playlist by Country'),
            
            # Create a sidebar layout for this tab (page)
            sidebarLayout(
              
              # Create a sidebarPanel for your controls
              sidebarPanel(
                
                # Make a textInput widget for searching for country playlist
                selectInput('country', label = "Select a Country", choices = countries)
              ),
              
              # Create a main panel, in which you should display your plotly Scatter plot
              mainPanel(
                tableOutput('table')
              )
            )
    ),
    tabPanel('Playlist Breakdown',
             # Add a titlePanel to tab
             titlePanel('Breakdown of Top Fifty Playlist by Country'),
             
             # Create a sidebar layout for this tab (page)
             sidebarLayout(
               
               # Create a sidebarPanel for your controls
               sidebarPanel(
                 
                 # Make a textInput widget for searching for country playlist
                 selectInput('country2', label = "Select a Country", choices = countries),
                 selectInput('feature', label = "Select an Audio Feature", choices = colnames(info.on.track.parsed.data)),
                 helpText("danceability = how suitable a track is for dancing based on tempo, rhythm and beat,
                          energy = measure of intensity and activity,
                          key = key track is in based on integer scale (0 = C, 1 = C♯/D♭, 2 = D, and so on),
                          loudness = loudness of a track in decibels,
                          mode = indicates if track is major or minor,
                          speechiness = presence of spoken word in track,
                          acousticness = confidence measure of track is acoustic,
                          instrumentalness = predicts whether a track contains no vocals
                          ")
               ),
               
               # Create a main panel, in which you should display your plotly Scatter plot
               mainPanel(
                 plotlyOutput('audio.analysis')
               )
             )
    )
    ))