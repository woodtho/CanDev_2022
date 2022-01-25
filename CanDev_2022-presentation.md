---
title: "Intro to Shiny"
author: "Thomas Wood"
date: "04/02/2022"
theme: readable 
output: 
  html_document:
    toc: true
    toc_depth: 3
    toc_float: true
    keep_md: yes
---



## Create a new shiny app

Open RStudio and go to:

`File > New Project... > New Directory > Shiny Web Application > Enter a directory name and location > Create project` 

R will open a new project for the shiny app, which will contain one file (`app.R`), which will have an example shiny app that you can run by clicking the `Run App` button (top right of the script panel).

This is the home of your app, and any data, pictures, etc. you needs for your app to run need to be stored in the same directory!

> Note: Sure you have shiny installed. `install.packages("shiny")`


## App structure

`app.R` has three components:

- a user interface object

- a server function

- a call to the `shinyApp()` function

The user interface (`ui`) object controls the layout and appearance of your app. The `server` function contains the instructions that a computer needs to build the app. Finally the `shinyApp` function creates the Shiny app from an explicit UI/server pair.

We'll talk more shortly about what goes into the UI and the Server shortly...

## Reactivity

Shiny is about making it easy to wire up input values from a web page, making them easily available to you in R, and have the results of your R code be written as output values back out to the web page.

The reactivity frame work used by shiny means that:

- You can change inputs at any time, and the outputs that are impacted will updated immediately to reflect those changes.

- All of this happens automatically, because Shiny is taking care of tracking "dependencies" for you.

- You can simply access the inputs from the browser, using a list-like syntax, and you don't have to worry about write code to monitor changes.

## App template (Default)

> All code in this demo that creates a shiny app can be copied directly into the console and run to create a shiny app. Please insure you have the required packages installed.


```r
install.packages("shiny")
```


Here are some templates that can be used to build a shiny app. This one creates an empty space where you can add your inputs, outputs, and other HTML.


```r
library(shiny)

ui <- fluidPage()

server <- function(input, output) { }

shinyApp(ui, server)
```

You can use functions like fluidRow() and column() to organize your layout. 

You can also use a higher-level function like sidebarLayout() add some structure to the app, dividing the space into a sidebarPanel(), and a mainPanel(). 


```r
library(shiny)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(),
    mainPanel()
    )
  )

server <- function(input, output) { }

shinyApp(ui, server)
```

You can then further organize the layout with fluidRows and columns. Notice that column widths in the same row need to sum to 12!


```r
library(shiny)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(),
    mainPanel(
      fluidRow(
        column(width = 6),
        column(width = 6)
        ),
      fluidRow(
        
        )
      )
    )
  )

server <- function(input, output) { }

shinyApp(ui, server)
```

To make this example a little clearer, we can add some content and optional styling to the app to illustrate where different content fits in the layout. 

- notice that we are using several html tags to add styling to the static elements we are creating. Some tags are available from shiny directly as functions (e.g. `div()`, `h*()`, etc.), with more tags available in the `tags` object.

- Also notice that we were able to adjust styling for elements like our rows and columns by passing a style argument. 


```r
library(shiny)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(),
    mainPanel(
      fluidRow(style = "border: 1px solid #000000;",
        column(width = 6, style = "border: 1px solid red;",
               tags$h1("a first level heading")),
        column(width = 6, style = "border: 1px solid red;",
               tags$button("a button"))
        ),
      fluidRow(style = "border: 1px solid #000000;",
        HTML("<h1>Some HTML written in a string and rendered with HTML()</h1>
             </hr>
             <h2> some more text</h2>"),
        tags$p("a paragraph")
        )
      )
    )
  )

server <- function(input, output) { }

shinyApp(ui, server)
```


## Building your app around **Inputs and outputs**

So far the apps we have seen have been very simple and only contained static elements that we created in the UI. But shiny is all about making things interactive. We do that by using inputs and outputs. 

### Inputs

- Created with an *Input() function
- Creates the HTML for your apps UI
- Sends values from the web page back to the server

| Function             | Collects                                                                                                 |
|----------------------|----------------------------------------------------------------------------------------------------------|
| actionButton()       | A button press                                                                                           |
| checkboxInput()      | The state of a check box (TRUE/FALSE)                                                                     |
| checkboxGroupInput() | The state of a group of check boxes (a vector of selected values)                                         |
| dateInput()          | A single date (a date)                                                                                   |
| dateRangeInput()     | A range of dates (a vector of the min and max date)                                                      |
| fileInput()          | A file                                                                                                   |
| numericInput()       | A numeric value                                                                                          |
| passwordInput()      | A password                                                                                               |
| radioButtons()       | The state of a group of radio buttons (Which option is selected)                                         |
| selectInput()        | The current selection(s) for a drop down list (vector of length 1, or more, that includes selected values)|
| sliderInput()        | A single number/date/date time or a range of the same (a single value, or a vector of the min and max)   |
| textInput()          | A character string  (the entered text)                                                                   |

#### Syntax

*Input(inputId, label, ...)

- inputId needs to be a string. You can't use special characters, other than underscores.
- label describes what the input is for to the user and can use special characters.
- ... means that there are some other specific arguments that are required, depending on the input being used (usually this is something like value or choices).

#### Example

When using a sidebarLayout() I typically place most of the inputs into the sidebarPanel and use the mainPanel for my outputs. Notice that the different inputs are separated with commas inside of the sidebarPanel.


```r
library(shiny)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(actionButton("actionbutton", "Action Button"),
                 checkboxInput("checkboxInput", "Check box", value = TRUE),
                 checkboxGroupInput("checkboxGroupInput", "Check box group", choices = c("A", "B", "C")),
                 dateInput("dateInput", "Date"),
                 dateRangeInput("dateRangeInput", "Date Range"),
                 fileInput("fileInput", "File"),
                 numericInput("numericInput", "Number", value = 10),
                 passwordInput("passwordInput", "Password"),
                 radioButtons("radioButtons", "Radio Buttons", choices = c("A", "B", "C")),
                 selectInput("selectInput", "Drop down", choices = c("A", "B", "C")),
                 sliderInput("sliderInput", "Silder", min = 1, max = 10, value = 5),
                 textInput("textInput", "Text")
                 ),
    mainPanel(
      
      )
    )
  )

server <- function(input, output) { }

shinyApp(ui, server)
```

### Outputs

- Created with *Output() functions.
- Two parts, a space in the UI for the output once it has been rendered by the server, and code in the server to create the output. 
- You must build the object in the server separately.

| Function             | Inserts              |
|----------------------|----------------------|
| dataTableOutput()    | An interactive table |
| tableOutput()        | A table              |
| imageOutput()        | An image             |
| plotOutput()         | A plot               |
| textOutput()         | Text                 |
| verbatimTextOutput() | Text                 |
| uiOutput()           | a Shiny UI element   |
| htmlOutput()         | Raw HTML             |

#### Syntax

*Output(outputId, ...)

- Output typically only require the outputId that is used by the server for saving the rendered html content

#### Example


```r
library(shiny)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(),
    mainPanel(
      dataTableOutput("dataTableOutput"),
      tableOutput("tableOutput"),
      plotOutput("plotOutput"),
      textOutput("textOutput"),
      verbatimTextOutput("verbatimTextOutput"),
      uiOutput("uiOutput")
      )
    )
  )

server <- function(input, output) { 
  
  output$dataTableOutput <- renderDataTable({ iris })
  
  output$tableOutput <- renderTable({ iris })
  
  output$plotOutput <- renderPlot({ plot(iris) })
  
  output$textOutput <- renderText({ "Some rendered text" })
  
  output$verbatimTextOutput <- renderText({ "Some rendered text" })
  
  output$uiOutput <- renderUI({ selectInput("input", "A rendered UI input", choices = c("A", "B", "C")) })
  
  }

shinyApp(ui, server)
```

- Notice that each output in the UI has a corresponding entry in the server.
- Each output in the server is saved into the `output` object (output$outputId)
- There are different rendering function used. These turn the outputs into HTML that can be shown in the UI

## Tell the server how to assemble inputs into outputs

### Save object to display to output$

After creating a place in the UI for the output, you need to write the code to create the output. The outputs always need to be saved into the `output` object. This looks like:


```r
server <- function(input, output) { 
  
  output$outputId <- # code to create the output, e.g., code that can make a plot, or a table
  
}
```

Every output in the UI needs to have a value created in the server

- for example: if you have `plotOutput("plot")` and `tableOutput("table")` in the UI, you need `output$plot` and `output$table` in the server.

### Build objects with render*()

Before an output can be displayed by the webpage, it must be rendered. Which function you use to render an output depends on the type of output. 

| Function          | Creates              |
|-------------------|----------------------|
| renderDataTable() | An interactive table |
| renderTable()     | A table              |
| renderPlot()      | A plot               |
| renderText()      | A character string   |
| renderUI()        | A Shiny UI element   |


```r
server <- function(input, output) { 
  
  output$plot <- renderPlot({
    
    plot(iris)
    
  })
  
  output$table <- renderDataTable({
    
    iris
    
  })
  
  # The same table, but rendered as a static table. 
  
  # output$table <- renderTable({  
  #   iris
  # })
}
```

### Access inputs with input$


```r
library(shiny)
library(tidyverse)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      sliderInput("n", "Number", min = 1, max = 100, value = 10),
      selectInput("species", "Species",choices = unique(iris$Species),selected = unique(iris$Species),
                  multiple = TRUE)
    ),
    mainPanel(
      tableOutput("table")
    )
    )
  )

server <- function(input, output) { 
  
  output$table <- renderTable({
    
    iris %>% 
      filter(Species %in% input$species) %>% 
      head(., n = input$n)
    
  })
  
  }

shinyApp(ui, server)
```

## Deploy your app

You can share a shiny app with anyone who has R and the required packages installed on their computer simply by sharing the code, and another required files, with them.

If you want to share a shiny app with the public, or someone who doesn't have R and the required packages, you need to deploy your app to a shiny server. Shinyapps.io provides a free service that lets you upload a limited number of apps (there are paid plans with more active hours that allow for more apps to be loaded). [You can look at this article for details on deploying apps to Shinyapps.io.](https://shiny.rstudio.com/articles/shinyapps.html)
