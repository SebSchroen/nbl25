# Boulder Multiplicator Dashboard

This Shiny application visualizes the distribution of "multiplicator" values for various climbing stations and classes, pulling real-time data from [bouldersport.de](https://bouldersport.de/wettkaempfe/spieltag/nbl25-station-1/).

## Features

- **Dynamic Data Loading**: Fetches and processes live data from the website.
- **Interactive Visualization**: Provides violin plots and boxplots for selected climbing classes and stations.
- **User-Friendly Interface**: Uses the `shinytheme` for a clean and responsive design.

## Dependencies

The application uses the following R packages:

- **shiny**: For creating the interactive web application.
- **rvest**: For web scraping the required data.
- **stringr**: For text manipulation and pattern matching.
- **readr**: For parsing numeric data.
- **tibble**: For working with data frames.
- **dplyr**: For data manipulation and filtering.
- **ggplot2**: For generating violin and box plots.
- **shinythemes**: For applying modern UI themes.
- **shinycssloaders**: For displaying loading spinners.

## How It Works

1. **Data Scraping and Processing**:
   - The app scrapes climbing competition data (station, class, boulder names, and multiplicator values) from the `bouldersport.de` website.
   - Data is dynamically processed and displayed in a user-friendly manner.

2. **Visualization**:
   - Users can select a climbing class from a dropdown menu.
   - The app displays a violin plot with a boxplot overlay, showing the distribution of multiplicator values across stations.

3. **Error Handling**:
   - The app gracefully handles missing or inaccessible data by skipping problematic entries.

## Setup and Usage

### Prerequisites

Ensure you have R and RStudio installed. You also need the following R libraries:

```R
install.packages(c("shiny", "rvest", "stringr", "readr", "tibble", "dplyr", "ggplot2", "shinythemes", "shinycssloaders"))
```

### Running the App

1. Save the script as `app.R`.
2. Run the app in RStudio or R terminal using the following command:

   ```R
   shiny::runApp('app.R')
   ```

3. Open the app in your browser. The default interface includes:
   - A dropdown menu to select a climbing class.
   - A dynamic violin plot visualizing the multiplicator values for the selected class.

## File Overview

- **app.R**: Main Shiny application script, containing both the UI and server logic.

## Credits

- Data Source: [Bouldersport.de](https://bouldersport.de)
- Developed using [R Shiny](https://shiny.rstudio.com/).

