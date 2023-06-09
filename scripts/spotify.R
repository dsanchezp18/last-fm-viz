# Using the package spotifyR

# Load the package

library(spotifyr)
library(tidyverse)

# Run the script to set the Spotify credentials (hidden)

source('scripts/credentials.R')

# Get the Spotify access token

access_token <- get_spotify_access_token(client_id = Sys.getenv('SPOTIFY_CLIENT_ID'),
                                         client_secret = Sys.getenv('SPOTIFY_CLIENT_SECRET'))

# Get stuff from Epica: at the album level.

epica <- 'epica'
epica_id <- '5HA5aLY3jJV7eimXWkRBBp'

epica_info <-
  get_artist(epica_id, access_token)

