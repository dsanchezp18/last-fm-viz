# Using R and Tableau to analyze music trends

This is the GitHub repository which holds all of the work required to reproduce this project. This can be done thanks to Piotr Patrzyk's [*lastfmR*](https://github.com/ppatrzyk/lastfmR) package.

The obtainment, cleaning and preliminary analysis of the data was done through R, and can be executed by downloading this repository to your computer and rendering the `.qmd` script or running all code chunks in that document. 

You may see the main visualization part of the project in my [Tableau Public account](https://public.tableau.com/app/profile/dsanchezp18/viz/VisualizingScrobblesfromLast_fm/VisualizingListeningTrends).

An interactive Shiny dashboard built with the **flexdashboard** package is also
available. Launch it with:

```r
rmarkdown::run("scripts/scrobbles_flexdashboard.Rmd")
```

