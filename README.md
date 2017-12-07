# Music Around the Globe

This is the code responsible for the creation of a shiny web application for highlighting the Top 50 songs played on Spotify in countries around the world.

Using **Spotify's Web API** we map this data onto a world map and analyze different audio features of the top tracks.

### Map
The **choropleth map** is the landing page for the web app. Here the average audio features of the top 50 songs of each country are displayed on a world map. The colors of each country with data correlates to their level of whichever audio feature is mapped. The user can choose which audio feature they'd like to see mapped from the sidebar widget.

### Playlist Summary
Displayed here is a top 50 playlist for a country selected by the user. Since the data is requested each time from the **Spotify Web API**, this data updates in real time.

### Playlist Breakdown
This tab uses **plotly** to generate various scatter plot charts for the audio feature and country selected by the user.

### About the Team
This web app was created by a group of students (Allen Acosta, Kyle Avalani, Ali Burke, Asikur Rahman) for the final project in UW's INFO201 class.
