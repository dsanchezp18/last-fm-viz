# Using the package spotifyR

# Load the package

library(spotifyr)
library(tidyverse)

# Set environment variables for spotify (so that the package works)

#Sys.setenv(SPOTIFY_CLIENT_ID = '')
#Sys.setenv(SPOTIFY_CLIENT_SECRET = '')

# Get the Spotify access token

access_token <- get_spotify_access_token()

# Get my all time top tracks

get_my_top_artists_or_tracks(type = 'artists', limit = 5) %>% 
  select(name, genres)