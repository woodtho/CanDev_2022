# Script name: R&D Personnel shiny app

# Author: Thomas Wood (thomas.wood@statcan.gc.ca)

# Date Created: 04-02-2022

# Notes: Any code that is above the UI in a shiny app is run once when the app
# is started. We can use this space to load the packages and read in some data
# to display

# Packages ----------------------------------------------------------------

# install.packages(c("tidyverse", "shiny", "scales"))

library(tidyverse) # Data manipulation and plotting
library(shiny) # Creates the shiny app
library(scales) # Formatting the scales and labels on the plot

# Data Import -------------------------------------------------------------

# Notice that the data files need to be located in the same directory as the
# app. When the app is deployed to a server, the server needs to be able to
# access the data, and it can only do that if the data is in a location the
# server can access.
rd_data <- read_csv("Data/27100337-eng/27100337.csv") %>%
  
  # This data cleaning is optional
  filter(
    !`Occupational category` %in% c(
      "Researchers and research managers",
      "Research and development technical, administrative and support staff"
    )
  ) %>%
  mutate(across(contains(" "), fct_inorder)) %>%
  mutate(across(`Occupational category`, fct_rev))

# We are referencing the min/max years from the data a lot, so I extracted them
# into variables
min_year <- min(rd_data$REF_DATE)
max_year <- max(rd_data$REF_DATE)

# UI code -----------------------------------------------------------------

ui <- fluidPage(# Add a title
  titlePanel("R&D Personnel"),
  
  # We will use a sidebarLayout to orginize our app, with the inputs in the
  # sidebarPanel, and the outputs in the mainPanel
  sidebarLayout(
    # By default the side bar has a width of 4, but we don't need that much space
    sidebarPanel(
      width = 3,
      
      # look for where input$year occurs in the server to see where the year
      # input impacts the data
      sliderInput(
        "year",
        "Year",
        sep = "",
        min = min_year,
        max = max_year,
        # we are using a vector here to have a slider with two values
        value = c(max_year - 2, max_year)
      ),
      
      # look for where input$category occurs in the server to see where the
      # category input impacts the data
      selectInput(
        'category',
        "Occupational category",
        
        # Using `unique()` lets the app read the choices from the
        # data. You can also manually supply choices using a vector
        # (e.g., `c("Choice 1", "Choice 2")`)
        choices = unique(rd_data$`Occupational category`),
        # Select all options by default
        selected = unique(rd_data$`Occupational category`),
        # You can use the multiple argument to control if the user can
        # select multiple options, or only on (the default)
        multiple = TRUE
      ),
      
      # look for where input$coc occurs in the server to see where the country
      # of control input impacts the data
      selectInput(
        "coc",
        "Country of control",
        # reading choices from the data again
        choices = unique(rd_data$`Country of control`)
      ),
      
      # look for where input$NAICS occurs in the server to see where the NAICS
      # input impacts the data
      selectInput(
        "NAICS",
        "North American Industry Classification System (NAICS)",
        choices = unique(rd_data$`North American Industry Classification System (NAICS)`)
      )
      
    ),
    
    # Outputs are in the mainPanel
    mainPanel(
      # Look at the output$plot expression in the server to see the code that
      # creates this output
      plotOutput("plot",
                 
                 # The default plot height can be kind of small, so I am
                 # increasing the height of the plot
                 height = "550px"),
      
      # Adding a horizontal line above the table to better distinguish between
      # the plot area and the table area
      hr(),
      
      # Look at the output$table expression in the server to see the code that
      # creates this output
      dataTableOutput("table")
    )
  ))



# Server Code -------------------------------------------------------------

server <- function(input, output) {
  # creates the html for plotOutput("plot")
  output$plot <- renderPlot({
    # This is a static dataframe that we created when the app was launched.
    rd_data %>%
      
      # We can filter that static df using the inputs to create a df that is
      # reactive to the inputs
      filter(
        # A two value slider returns a vector with the min and max values of the
        # slider. Using the between function to check that the REF_DATE falls
        # within that range from the slider
        between(REF_DATE, min(input$year), max(input$year)),
        
        # Single selectInputs() return a single string that we can filter against
        `Country of control`	== input$coc,
        `North American Industry Classification System (NAICS)` == input$NAICS,
        
        # input$category accepts multiple selections, so we are checking that
        # the value is in the vector returned by input$category
        `Occupational category` %in% input$category
      ) %>%
      
      ggplot(
        aes(
          x = as.factor(REF_DATE),
          y = VALUE,
          fill = `Occupational category`,
          group = `Occupational category`,
          label = comma(VALUE, accuracy = 1, suffix = " FTE")
        )
      ) +
      
      geom_col(position = position_dodge()) +
      geom_label(position = position_dodge(width = 0.9),
                 alpha = 0.5,
                 fill = "white") +
      
      coord_flip() +
      scale_fill_discrete(guide = guide_legend(
        title.position = "top",
        title.hjust = 0.5,
        ncol = 2,
        reverse = TRUE
      )) +
      scale_y_continuous(labels = comma_format(),
                         breaks = pretty_breaks(10)) +
      theme_minimal(base_size = 20) +
      theme(legend.position = "bottom") +
      labs(x = "",
           y = "full-time equivalent (FTE)")
    
  })
  
  output$table <- renderDataTable({
    rd_data %>%
      filter(
        between(REF_DATE, min(input$year), max(input$year)),
        `Country of control`	== input$coc,
        `North American Industry Classification System (NAICS)` == input$NAICS,
        `Occupational category` %in% input$category
      ) %>%
      select(-DGUID, -GEO,-UOM:-COORDINATE,-SYMBOL:-DECIMALS) %>%
      arrange(
        REF_DATE,
        `North American Industry Classification System (NAICS)`,
        `Country of control`,
        desc(`Occupational category`)
      )
    
  })
  
}


# Launch the app ----------------------------------------------------------


shinyApp(ui, server)
