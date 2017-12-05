# ui.R
library(shiny)
library(plotly)

source("country-playlist-data.R")
source("data-wrangling.R")

shinyUI(navbarPage('Music Around the Globe',
  # Create a tab panel for map
    tabPanel('Map',
            titlePanel('Music by Country'),
            # Create sidebar layout
            sidebarLayout(
              
              # Side panel for controls
              sidebarPanel(
                
                # Input to select variable to map
                # Changes hover info
                selectInput('mapvar', label = 'Variable to Map', choices = list("Top 5 Songs" = 'songs', 'Top 5 Artists' = 'artists', 'Average song features' = 'features'))
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
                 selectInput('country', label = "Select a Country", choices = countries),
                 selectInput('feature', label = "Select an Audio Feature", choices = colnames(info.on.track.parsed.data))
               ),
               
               # Create a main panel, in which you should display your plotly Scatter plot
               mainPanel(
                 plotlyOutput('audio.analysis')
               )
             )
    )
    ))