#+
#--app.R file for Project 3 of CS 424 - Group 4-------
#-----------------------------------------------------
#--Amber Little------*********************************
#--Charly Sandoval---*********************************
#--Matt Jankowski----*********************************
#-----------------------------------------------------

library(shiny)
library(shinydashboard)


#IMPORTANT: app.R needs "dark_theme_mod.R" in the same directory to run well with the dark theme:
source("dark_theme_mod.R") #connect

#NOTE: the data file to be read here is first processed by our Python scripts.
#READ IN THE DATA FILES:

certificates <- read.csv(file = "csvFiles/final_csvFiles/certificates-cleaned-final.csv",sep=",", header= TRUE)
genres <- read.csv(file="csvFiles/final_csvFiles/genres-cleaned-final.csv",sep=",", header=TRUE)
keyWords <- read.csv(file="csvFiles/final_csvFiles/keywords-movies-cleaned-final.csv",sep=",", header=TRUE)
movies <- read.csv(file="csvFiles/final_csvFiles/movies-cleaned-final.csv",sep=",",header=TRUE)
releaseDates <- read.csv(file="csvFiles/final_csvFiles/release-dates-cleaned-final.csv",sep=",",header=TRUE)
runningTimes <- read.csv(file="csvFiles/final_csvFiles/running-times-cleaned-final.csv",sep=",")



#SHINY DASHBOARD:

ui <- dashboardPage(
  
  #Header
  dashboardHeader(title = "Saturday Night at the Movies"),
  
  #Sidebar
  dashboardSidebar(disable = FALSE, collapsed = FALSE
                   
      
    #insert inputs here
      
      

    
      
  ),
  
  
  #Body
  dashboardBody(
    
    dark_theme_mod,  # dark theme
    
    
    
    # APPLICATION LAYOUT COMPONENTS:
    fluidRow(
     
      column(12,

             
        tabsetPanel(
         
          tabPanel ( "Analysis" 
                    
            #outputs here
                  
          ), # End tab1

          
                
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

  
  # REACTIVE FUNCTIONS:
  
  
  

  
  
  # BACKEND COMPONENTS:
  
  
  
  
  
  
}#end server block

shinyApp(ui = ui, server = server)  #use ui and server in shiny app