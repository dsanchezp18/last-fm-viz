###############################################################################################################

# Using R and Tableau to analyze music trends
# Daniel Sánchez Pazmiño

###############################################################################################################

# Preliminaries -------------------------------------------------------------------------------------------

# Load libraries

if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org") # The tidyverse

# Use remotes::install_github("ppatrzyk/lastfmR") to install the lastfmR package

library(lastfmR)

# Acquire data from Lastfm --------------------------------------------------------------------------------



