# ui.R
library(shiny)
library(plotly)

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
            titlePanel('Top Fifty Playlists by Country'),
            
            # Create a sidebar layout for this tab (page)
            sidebarLayout(
              
              # Create a sidebarPanel for your controls
              sidebarPanel(
                
                # Make a textInput widget for searching for country playlist
                textInput('search', label="Find a Country", value = '')
              ),
              
              # Create a main panel, in which you should display your plotly Scatter plot
              mainPanel(
                plotlyOutput('scatter')
              )
            )
    )
    ))