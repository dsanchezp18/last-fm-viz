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
  titlePanel("Visualizing Scrobbles from Last.fm with Shiny"),
  sidebarLayout(
    sidebarPanel(
      dateRangeInput(
        "date_range",
        "Date range",
        start = min(scrobbles$day),
        end = max(scrobbles$day)
      ),
      selectizeInput(
        "year",
        "Year",
        choices = c("All", sort(unique(year(scrobbles$date)))),
        selected = "All",
        multiple = FALSE
      ),
      selectizeInput(
        "month",
        "Month",
        choices = c("All", month.name),
        selected = "All",
        multiple = FALSE
      ),
      selectizeInput(
        "period",
        "Period",
        choices = c("All", sort(unique(format(scrobbles$date, "%Y-%m")))),
        selected = "All",
        multiple = FALSE
      ),
      textInput(
        "artist",
        "Artist (search)",
        value = "",
        placeholder = "Search for artist..."
      ),
      textInput(
        "album",
        "Album (search)",
        value = "",
        placeholder = "Search for album..."
      ),
      textInput(
        "track",
        "Track (search)",
        value = "",
        placeholder = "Search for track..."
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
          plotOutput("time_plot", 
                    click = "time_plot_click",
                    dblclick = "time_plot_dblclick"),
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
  # Reactive values for drill-down functionality
  values <- reactiveValues(
    drill_level = "year",  # Can be "year", "month", or "day"
    selected_year = NULL,
    selected_month = NULL
  )
  
  filtered <- reactive({
    df <- scrobbles %>%
      filter(day >= input$date_range[1], day <= input$date_range[2])
    
    if (input$year != "All") {
      df <- df %>% filter(year(date) == as.numeric(input$year))
    }
    
    if (input$month != "All") {
      df <- df %>% filter(month(date, label = TRUE, abbr = FALSE) == input$month)
    }
    
    if (input$period != "All") {
      df <- df %>% filter(format(date, "%Y-%m") == input$period)
    }
    
    if (input$artist != "") {
      df <- df %>% filter(grepl(input$artist, artist, ignore.case = TRUE))
    }
    
    if (input$album != "") {
      df <- df %>% filter(grepl(input$album, album, ignore.case = TRUE))
    }
    
    if (input$track != "") {
      df <- df %>% filter(grepl(input$track, track, ignore.case = TRUE))
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
    df <- filtered()
    
    if (values$drill_level == "year") {
      # Year level - show scrobbles by year
      plot_data <- df %>%
        mutate(year = year(date)) %>%
        count(year) %>%
        mutate(label = as.character(year))
      
      p <- ggplot(plot_data, aes(x = reorder(label, year), y = n)) +
        geom_col(fill = "steelblue", alpha = 0.8) +
        labs(x = "Year", y = "Total Scrobbles", 
             title = "Scrobbles by Year (Click to drill down to months)") +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
      
    } else if (values$drill_level == "month") {
      # Month level - show scrobbles by month for selected year
      plot_data <- df %>%
        filter(year(date) == values$selected_year) %>%
        mutate(
          month_num = month(date),
          month_name = month(date, label = TRUE, abbr = FALSE)
        ) %>%
        count(month_num, month_name) %>%
        mutate(label = as.character(month_name))
      
      p <- ggplot(plot_data, aes(x = reorder(label, month_num), y = n)) +
        geom_col(fill = "darkgreen", alpha = 0.8) +
        labs(x = "Month", y = "Total Scrobbles",
             title = paste("Scrobbles by Month in", values$selected_year, "(Click to drill down to days)")) +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
      
    } else {
      # Day level - show scrobbles by day for selected month and year
      plot_data <- df %>%
        filter(
          year(date) == values$selected_year,
          month(date) == values$selected_month
        ) %>%
        count(day) %>%
        mutate(label = format(day, "%d"))
      
      p <- ggplot(plot_data, aes(x = day, y = n)) +
        geom_col(fill = "darkred", alpha = 0.8) +
        labs(x = "Day", y = "Total Scrobbles",
             title = paste("Scrobbles by Day in", 
                          month.name[values$selected_month], 
                          values$selected_year)) +
        theme_minimal() +
        scale_x_date(date_labels = "%d", date_breaks = "3 days")
    }
    
    p
  })
  
  # Handle click events for drill-down
  observeEvent(input$time_plot_click, {
    click_data <- input$time_plot_click
    df <- filtered()
    
    if (values$drill_level == "year") {
      # Drill down to month level
      if (!is.null(click_data$x)) {
        # Find the clicked year
        years <- df %>%
          mutate(year = year(date)) %>%
          count(year) %>%
          arrange(year) %>%
          pull(year)
        
        clicked_year <- years[round(click_data$x)]
        values$selected_year <- clicked_year
        values$drill_level <- "month"
      }
    } else if (values$drill_level == "month") {
      # Drill down to day level
      if (!is.null(click_data$x)) {
        # Find the clicked month
        months <- df %>%
          filter(year(date) == values$selected_year) %>%
          mutate(month_num = month(date)) %>%
          count(month_num) %>%
          arrange(month_num) %>%
          pull(month_num)
        
        clicked_month <- months[round(click_data$x)]
        values$selected_month <- clicked_month
        values$drill_level <- "day"
      }
    }
  })
  
  # Reset drill-down when filters change
  observeEvent(list(input$date_range, input$year, input$month, input$period, 
                   input$artist, input$album, input$track), {
    values$drill_level <- "year"
    values$selected_year <- NULL
    values$selected_month <- NULL
  })
  
  # Add a reset button functionality (double-click to reset)
  observeEvent(input$time_plot_dblclick, {
    values$drill_level <- "year"
    values$selected_year <- NULL
    values$selected_month <- NULL
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
