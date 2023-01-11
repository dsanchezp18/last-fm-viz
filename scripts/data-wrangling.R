###############################################################################################################

# Using R and Tableau to analyze music trends
# Daniel Sánchez Pazmiño

###############################################################################################################

# Preliminaries -------------------------------------------------------------------------------------------

# Load libraries

# The tidyverse

if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org") 

# This if statement installs and loads the package if not installed

# Use remotes::install_github("ppatrzyk/lastfmR") to install the lastfmR package

library(lastfmR)

# Acquire data from Lastfm --------------------------------------------------------------------------------

scrobbles <- get_scrobbles(user = 'damage_inc7')

# Wrangle the lastfm data ---------------------------------------------------------------------------------

# Export data to csv files --------------------------------------------------------------------------------

# Export the scrobble data frame

write.csv(scrobbles, 'data/scrobbles.csv')
