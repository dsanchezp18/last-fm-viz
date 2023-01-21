# Using the package spotifyR

# Load the package

library(spotifyr)
library(tidyverse)

# Get the Spotify access token

access_token <- get_spotify_access_token()


# Get my all time top tracks


top_tracks <-
  get_my_top_artists_or_tracks(type = 'tracks', time_range = 'long_term', limit = 50) %>% 
  select(name)