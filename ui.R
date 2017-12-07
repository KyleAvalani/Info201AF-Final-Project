# ui.R
library(shiny)
library(plotly)
library(shinythemes)

source("country-playlist-data.R")
source("data-wrangling.R")

average.values.choices <- list("Average Danceability" = 'dance.avg', "Average Energy" = 'energy.avg', "Average Key" = 'key.avg',
                               "Average Loudness" = 'loudness.avg', "Average Mode" = 'mode.avg', "Average Speechiness" = 'speechiness.avg',
                               "Average Acousticness" = 'acousticness.avg', "Average Instrumentalness" = 'instrumentalness.avg',
                               "Average Liveness" = 'liveness.avg', "Average Valence" = 'valence.avg', "Average Tempo" = 'tempo.avg',
                               "Average Duration" = 'duration.avg')

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
                selectInput('mapvar', label = 'Variable to Map', choices = average.values.choices)
              ),
              
              # Main panel: display plotly map
              mainPanel(
                h1("Hello!"),
                h5("This is a web application that was created by means of the Spotify Web API"),
                h5("that shows the Top 50 charts for featured countries as well as analyzes"),
                h5("the songs within those playlists for numerous different audio features,"),
                h5("such as danceability and acousticness."),
                h1(""),
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
                 helpText("danceability = how suitable a track is for dancing based on tempo", 
                          "rhythm and beat"), 
                 br(),
                 helpText("energy = measure of intensity and activity"), 
                 br(),
                 helpText("key = key track is in based on integer scale (0 = C, 1 = C♯/D♭, 2 = D, and so on)" ),
                 br(),
                 helpText("loudness = loudness of a track in decibels") ,
                 br(),
                 helpText("mode = indicates if track is major or minor") ,
                 br(), 
                 helpText("speechiness = presence of spoken word in track") ,
                 br(), 
                 helpText("acousticness = confidence measure of track is acoustic") ,
                 br(), 
                 helpText("instrumentalness = predicts whether a track contains no vocals") 
               ),
               
               
               # Create a main panel, in which you should display your plotly Scatter plot
               mainPanel(
                 plotlyOutput('audio.analysis')
               )
             )
    )
    ))