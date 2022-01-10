
library(shiny)
library(shinydashboard)
library(tidyverse)

min_year <- min(province_rd$REF_DATE)
max_year <- max(province_rd$REF_DATE)

ui <- dashboardPage(
    dashboardHeader(title = "R&D"),
    dashboardSidebar(
      sidebarMenu(
        selectInput("naics", 
                    label = "North American Industry Classification System (NAICS)", 
                    choices = unique(province_rd$`North American Industry Classification System (NAICS)`)), 
        selectInput("coc", 
                    label = "Country of control", 
                    choices = unique(province_rd$`Country of control`)),
        selectInput("dollar_v_people",
                    label = "Dollars or people?",
                    choices = unique(province_rd$UOM)),
        sliderInput("year",
                    label = "Year",
                    value = max_year,
                    step = 1,
                    min = min_year,
                    max = max_year, 
                    sep = "",
                    ticks = FALSE)
      )),
    dashboardBody(
      fluidRow(box(title = "Map", 
                   plotOutput("map")),
               box(title = "breakdowns",
                   plotOutput("breakdown"))),
    fluidRow(column(12, dataTableOutput(outputId = "data"))))
)
