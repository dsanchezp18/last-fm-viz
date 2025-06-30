### Using R to analyze Epica's stream data ###
# Daniel Sánchez Pazmiño

# Preliminaries -------------------------------------------------------------------------------------------

# Load libraries

# The tidyverse

if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")

# This if statement installs and loads the package if not installed

# Use remotes::install_github("ppatrzyk/lastfmR") to install the lastfmR package

library(lastfmR)

