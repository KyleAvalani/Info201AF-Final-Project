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
                h1("Hello!"),
                h5("This is a web application that was created by means of the Spotify Web API"),
                h5("that shows the Top 50 charts for featured countries as well as analyzes"),
                h5("the songs within those playlists for numerous different audio features,"),
                h5("such as danceability and acousticness."),
                h1(""),
                plotlyOutput('map'),
                #h5("<a href='https://developer.spotify.com/web-api/user-guide/'>Spotify API</a>")
                h5(a("Spotify API", href="https://developer.spotify.com/web-api/user-guide/"), target="_blank", align = "right", a("Chloropleth Map", href="https://plot.ly/r/choropleth-maps/"), target="_blank" )
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
                 helpText("Danceability = how suitable a track is for dancing.",
                          "Energy = measure of intensity and activity.",
                          "Key = key track is in based on integer scale", 
                          "(0 = C, 1 = C#/C♭, 2 = D, and so on).",
                          "Loudness = loudness of a track in decibels.",
                          "Mode = indicates if track is major or minor.",
                          "Speechiness = presence of spoken word in track.",
                          "Acousticness = confidence measure of track is acoustic.",
                          "Instrumentalness = predicts whether a track contains no vocals.")
               ),
               
               # Create a main panel, in which you should display your plotly Scatter plot
               mainPanel(
                 plotlyOutput('audio.analysis')
               )
             )
    )
    ))