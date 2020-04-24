#+
#--app.R file for Project 3 of CS 424 - Group 4-------
#-----------------------------------------------------
#--Amber Little------*********************************
#--Charly Sandoval---*********************************
#--Matt Jankowski----*********************************
#-----------------------------------------------------

library(shiny)
library(shinydashboard)
library(ggplot2)
library(lubridate)
library(DT)
library(jpeg)
library(grid)
library(leaflet)
library(scales)
library(hashmap)
library(plyr)
library(devtools)        #for theme
library(dashboardthemes) #for theme
library(hflights)
library(repurrrsive)
library(tidyverse)
library(RColorBrewer)

#IMPORTANT: app.R needs "dark_theme_mod.R" in the same directory to run well with the dark theme:
source("dark_theme_mod.R") #connect

#NOTE: the data file to be read here is first processed by our Python script.
#READ IN THE DATA FILES:




#SHINY DASHBOARD:

ui <- dashboardPage(
  
  #Header
  dashboardHeader(title = "Saturday Night at the Movies"),
  
  #Sidebar
  dashboardSidebar(disable = FALSE, collapsed = FALSE
                   
      
    #insert inputs here
      
      
      
      
      
      
      
      
      
  ),
  
  
  #Body - is made of tabs, which house individual components
  dashboardBody(
    
    dark_theme_mod,  # dark theme
    
    # APPLICATION LAYOUT: ----layout components here: ------------------------------------------------------
    fluidRow(
     
      column(12,

             
        tabsetPanel(
         
          tabPanel ( "Analysis" 
                    
            #outputs here
            
            
            
                    
                  
          ), # End tab1
          # -------------------------------------------------------------------------------------------------------------------------------------------- #
          
          
          tabPanel ( "About" ,
                     
            h2("Saturday Night at the Movies"),
            h3("Developed By: Amber Little, Charly Sandoval, and Matt Jankowski"),
            h4("Project 3 in CS 424 (Data Analytics / Visualization) at the University of Illinois at Chicago Spring 2020"),
            h5("________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________"),
            h5("* Libraries Used: "),
            h5("* Data Source: "),
            h5("* Created using R, RStudio, Shiny, Python, [insert theme credit here]")
          ) # End about tab
         
         
        ) #End tabsetPanel
      ) # End column
    ) # End fluid row
  ) # End dash board body

  
  
) # End dashboard page


# SERVER SIDE:
server <- function(input, output, session) {

  
  #REACTIVE FUNCTIONS:
  
  
  

  
  
  # BACKEND LAYER: ---- backend components here: ------------------------------------------------------
  

  #backend output here
  
  
  #backend components above  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  
}#end server block

shinyApp(ui = ui, server = server)  #use ui and server in shiny app