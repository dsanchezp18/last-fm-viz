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

# Get stuff from Epica: at the song level (from albums)

phantom_agony_id <- '5qBmY4zyWEYP8bNJsq9Xjf'

songs_phantom <-
  get_album_tracks(phantom_agony_id,
                   authorization = access_token)

cry_for_the_moon_id <- '66iX4HzM7YnmxmUZOSCG2F'

cry_for_the_moon <-
  get_track(cry_for_the_moon_id)
