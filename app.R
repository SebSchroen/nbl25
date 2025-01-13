library(shiny)
library(rvest)
library(stringr)
library(readr)
library(tibble)
library(dplyr)
library(ggplot2)
library(shinythemes)
library(shinycssloaders) # For loading screen
library(tidyr)

# Define UI for application
ui <- fluidPage(
  theme = shinytheme("cerulean"), # Use a nice theme
  titlePanel("Boulder Multiplicator Dashboard"),
  sidebarLayout(
    sidebarPanel(
      selectInput("selectedClass", "Select Class:",
                  choices = NULL),  # Choices will be set dynamically
      hr(),
      p("Data is pulled from:", a("bouldersport.de", href="https://bouldersport.de/wettkaempfe/spieltag/nbl25-station-1/"))
    ),
    mainPanel(
      withSpinner(plotOutput("violinPlot"), type = 4) # Wrap plot with loading spinner
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  
  # 1. Initial data loading and processing - runs once
  all_data <- reactiveVal(NULL) # Initialize with NULL for loading check
  data_loaded <- reactiveVal(FALSE) # Flag to indicate data loaded
  
  
  # Setup initial data - make it reactive so it doesn't load on every event
  observeEvent(TRUE, {
    # Show a notification while loading
    showNotification("Loading data from the web, this might take a while...", duration = NULL, closeButton = FALSE, id = "loading_data_notification")
    names <- tibble(station_id = c(1, 5, 3, 4),
                    station_name = c("Escaladrome", "Beta", "Greifhaus", "BiG"))
    id <- c(1,5,3,4)
    classes <- tibble(class_id = c(1:6),
                      name = c("Power Herren", "Power Damen",
                               "Relax Herren","Relax Damen",
                               "Ü40 Herren","Ü40 Damen"))
    ids <- crossing(classes$class_id, names$station_id) %>%
      rename(class_id = `classes$class_id`,
             station_id = `names$station_id`)
    
    # Using lapply instead of foreach for cleaner code and no dependency
    relax <- lapply(1:nrow(ids), function(i) {
      station <- ids$station_id[i]
      tryCatch({
        station3 <- read_html(paste0("https://bouldersport.de/wettkaempfe/spieltag/nbl25-station-", station, "/"))
        boulderlisten <- station3 %>% html_elements(xpath = "//*[contains(@class, 'wrapper')]")
        stuff <- html_text(boulderlisten)
        class <- ids$class_id[i]
        relax_clean <- stringr::str_split(stuff[class], "")
        regex_pattern <- "Bonus([0-9]+\\.[0-9]+)Multiplikator"
        multiplikator_raw <- str_extract_all(relax_clean, regex_pattern)
        names_raw <- str_extract_all(relax_clean, "#\\d+\\s(.*?)\\s-")
        tibble(station_id = station,
               class_id = class,
               boulder_name = str_remove(names_raw[[1]], " -"),
               multiplikator = as.numeric(parse_number(multiplikator_raw[[1]])) )
      }, error = function(e) {
        NULL  # Return NULL if there is an error and skip this entry
      })
    })
    
    
    relax <- bind_rows(relax)  # Combine the list of tibbles into one
    relax_final <- left_join(relax, names , by = "station_id") %>%
      left_join(., classes, by = c("class_id" = "class_id"))
    
    all_data(relax_final) # Update data
    data_loaded(TRUE)     # Set flag to indicate that data is loaded
    
    updateSelectInput(session, "selectedClass",
                      choices = unique(relax_final$name),
                      selected = unique(relax_final$name)[1] # Set the default to the first class
    )
    removeNotification(id = "loading_data_notification") # Remove the loading notification
    
  })
  
  
  
  # 2. Create the violin plot
  output$violinPlot <- renderPlot({
    req(data_loaded()) # Wait until data is loaded
    selected_class <- input$selectedClass
    
    filtered_data <- all_data() %>%
      filter(name == selected_class)
    
    
    if(nrow(filtered_data) > 0){
      ggplot(data = filtered_data, aes(x = station_name, y = multiplikator)) +
        geom_violin(fill = "lightblue", color = "grey", alpha = 0.7) +
        geom_boxplot(width = 0.1, fill = "white", color = "black") +
        labs(title = paste("Multiplicator Distribution for", selected_class),
             x = "Station Name",
             y = "Multiplicator Value") +
        theme_minimal() +
        theme(plot.title = element_text(hjust = 0.5))
    } else {
      ggplot() +
        geom_text(aes(x=0.5, y=0.5, label = "No data for selected class"), size = 6) +
        theme_void()
    }
    
  })
}

# Run the application
shinyApp(ui = ui, server = server)