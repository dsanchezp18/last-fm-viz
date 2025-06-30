###############################################################################################################

# Using R and Tableau to analyze music trends
# Daniel Sánchez Pazmiño

###############################################################################################################

# Preliminaries ---------------------------------------------------------------

# Load libraries

# The tidyverse

if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")

# This if statement installs and loads the package if not installed

# Use remotes::install_github("ppatrzyk/lastfmR") to install the lastfmR package

library(lastfmR)
library(shiny)
library(readr)
library(dplyr)
library(ggplot2)
library(lubridate)


# Load data ---------------------------------------------------------------
scrobbles <- read_csv("data/scrobbles.csv", show_col_types = FALSE)
scrobbles$date <- as.POSIXct(scrobbles$date, tz = "UTC")
scrobbles$day <- as.Date(scrobbles$date)

# Build the Shiny UI -------------------------------------------------------

ui <- fluidPage(
  titlePanel("Last.fm Listening Trends"),
  sidebarLayout(
    sidebarPanel(
      dateRangeInput(
        "date_range",
        "Date range",
        start = min(scrobbles$day),
        end = max(scrobbles$day)
      ),
      selectizeInput(
        "artist",
        "Artist",
        choices = c("All", sort(unique(scrobbles$artist))),
        selected = "All",
        multiple = FALSE
      ),
      numericInput(
        "top_n",
        "Number of top artists/tracks",
        value = 10,
        min = 5,
        max = 20
      )
    ),
    mainPanel(
      fluidRow(
        column(4, textOutput("total_scrobbles")),
        column(4, textOutput("total_artists")),
        column(4, textOutput("total_tracks"))
      ),
      tabsetPanel(
        tabPanel(
          "Overall Trends",
          plotOutput("time_plot"),
          plotOutput("top_artists")
        ),
        tabPanel(
          "Artist Details",
          plotOutput("top_tracks"),
          plotOutput("heatmap")
        )
      )
    )
  )
)

# Define server -----------------------------------------------------------

server <- function(input, output, session) {
  filtered <- reactive({
    df <- scrobbles %>%
      filter(day >= input$date_range[1], day <= input$date_range[2])
    if (input$artist != "All") {
      df <- df %>% filter(artist == input$artist)
    }
    df
  })

  output$total_scrobbles <- renderText({
    paste("Total scrobbles:", nrow(filtered()))
  })

  output$total_artists <- renderText({
    paste("Unique artists:", length(unique(filtered()$artist)))
  })

  output$total_tracks <- renderText({
    paste("Unique tracks:", length(unique(filtered()$track)))
  })

  output$time_plot <- renderPlot({
    filtered() %>%
      count(day) %>%
      ggplot(aes(day, n)) +
      geom_line(color = "steelblue") +
      labs(x = "Date", y = "Scrobbles per day")
  })

  output$top_artists <- renderPlot({
    filtered() %>%
      count(artist, sort = TRUE) %>%
      slice_head(n = input$top_n) %>%
      mutate(artist = reorder(artist, n)) %>%
      ggplot(aes(artist, n)) +
      geom_col(fill = "darkred") +
      coord_flip() +
      labs(x = NULL, y = "Scrobbles")
  })

  output$top_tracks <- renderPlot({
    filtered() %>%
      count(track, sort = TRUE) %>%
      slice_head(n = input$top_n) %>%
      mutate(track = reorder(track, n)) %>%
      ggplot(aes(track, n)) +
      geom_col(fill = "darkgreen") +
      coord_flip() +
      labs(x = NULL, y = "Scrobbles")
  })

  output$heatmap <- renderPlot({
    filtered() %>%
      mutate(
        hour = hour(date),
        weekday = wday(date, label = TRUE)
      ) %>%
      count(weekday, hour) %>%
      ggplot(aes(hour, weekday, fill = n)) +
      geom_tile() +
      scale_fill_viridis_c() +
      scale_x_continuous(breaks = seq(0, 23, by = 4)) +
      labs(x = "Hour of day", y = "Day of week", fill = "Scrobbles")
  })
}

# Run the app -------------------------------------------------------------

shinyApp(ui, server)
