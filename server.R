
library(shiny)
library(shinydashboard)
library(tidyverse)
library(ggthemes)
library(DT)

province_rd <- read_csv("Data/27100341-eng/27100341.csv") %>%
  mutate(VALUE = if_else(SCALAR_FACTOR == "millions", VALUE * 1.0e+06, VALUE)) %>%
  mutate(across(
    .cols = c("Research and development characteristics",
              "GEO"),
    fct_inorder
  ))

map_df <- mapcan::mapcan(type = "standard", boundaries = "province")

  

shinyServer(function(input, output) {

  data <- reactive({
    province_rd %>%
      filter(
        `North American Industry Classification System (NAICS)` == input$naics,
        `Country of control` == input$coc,
        UOM == input$dollar_v_people,
        REF_DATE %in% input$year
      )
    
  })
  
  output$data <- renderDataTable({
    
    res <- data() %>% 
      select(
        -ends_with("_ID"),
        -DGUID,
        -UOM,
        -COORDINATE,
        -SYMBOL,
        -TERMINATED,
        -DECIMALS,
        -STATUS,
        -VECTOR,
        -SCALAR_FACTOR
      ) %>%
      arrange(REF_DATE, GEO, `Research and development characteristics`) %>%
      datatable(options = list(pageLength = 10))
    
    
    if(input$dollar_v_people == "Dollars"){
      res %>%
      formatCurrency(columns = 'VALUE') 
    } else {
      res %>% formatRound(columns = "VALUE", digits = 0)
    }
    
  })
  
  output$map <- renderPlot({
    
    p <- data() %>% 
      full_join(map_df, by = c("GEO" = "pr_english")) %>%
      filter(`Research and development characteristics` == if_else(input$dollar_v_people == "Dollars",
             "Total in-house research and development expenditures", 
             "Total in-house research and development personnel")) %>% 
      ggplot(aes(long, lat, group = group, fill = VALUE)) +
      geom_polygon(colour = "black") + 
      coord_fixed() +
      scale_y_continuous(expand = c(0,0))+
      scale_x_continuous(expand = c(0,0))+
      theme_void()
    
    if(input$dollar_v_people == "Dollars"){
      p + scale_fill_continuous_tableau("Blue",
                                        labels = scales::dollar_format(scale = 1/1.0e+6), 
                                        breaks = scales::pretty_breaks(5),
                                        name = "Dollars") +
        labs(title = "")
    } else {
      p + scale_fill_continuous_tableau("Blue",
                                        labels = scales::comma_format(), 
                                        breaks = scales::pretty_breaks(5),
                                        name = "FTEs")
    }
    
    
    
  })
  
  output$breakdown <- renderPlot({
    
    data() %>% 
      filter(UOM == input$dollar_v_people, 
             `Research and development characteristics` != if_else(input$dollar_v_people == "Dollars",
                                                                   "Total in-house research and development expenditures", 
                                                                   "Total in-house research and development personnel")) %>% 
      ggplot(aes(x = GEO, 
                 y = VALUE, 
                 fill = `Research and development characteristics` )) +
      geom_col(position="fill") +
      geom_hline(yintercept = c(0.25, .5, .75)) +
      coord_flip() + 
      theme_void() +
      scale_fill_tableau(palette = "Classic Cyclic",
                         guide = guide_legend(nrow = 3, title.position = "top", title.hjust = 0.5, reverse = TRUE))+
      theme(legend.position="bottom",
            axis.text.y = element_text(hjust = 1, margin = margin(0, 10, 0, 0)), 
            axis.line.y = element_line(),
            panel.grid.major.y = element_line(colour = "grey", linetype = "dashed"))
      
      
    
  })

})
