#+
#--app.R file for Project 3 of CS 424 - Group 4-------
#-----------------------------------------------------
#--Amber Little------*********************************
#--Charly Sandoval---*********************************
#--Matt Jankowski----*********************************
#-----------------------------------------------------

library(shiny)
library(shinydashboard)
library(devtools)        #for theme
library(dashboardthemes) #for theme
library(ggplot2)


#IMPORTANT: app.R needs "dark_theme_mod.R" in the same directory to run well with the dark theme:
source("dark_theme_mod.R") #connect

#NOTE: the data file to be read here is first processed by our Python scripts.
#READ IN THE DATA FILES:

#certificates <- read.csv(file = "csvFiles/final_csvFiles/certificates-cleaned-final.csv",sep=",", header= TRUE)
genres <- read.csv(file="csvFiles/final_csvFiles/genres-cleaned-final.csv",sep=",", header=TRUE)
#keyWords <- read.csv(file="csvFiles/final_csvFiles/keywords-movies-cleaned-final.csv",sep=",", header=TRUE)
#movies <- read.csv(file="csvFiles/final_csvFiles/movies-cleaned-final.csv",sep=",",header=TRUE)
#releaseDates <- read.csv(file="csvFiles/final_csvFiles/release-dates-cleaned-final.csv",sep=",",header=TRUE)
#runningTimes <- read.csv(file="csvFiles/final_csvFiles/running-times-cleaned-final.csv",sep=",")



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
        tabsetPanel(
    
          tabPanel ( "Analysis", 
                          
                     
             column(4,
                    
                    fluidRow(       
                        box(title = "Movies by Year", background = "black", solidHeader = TRUE, status = "primary", width= 12,
                            plotOutput("yearBarGraph", height = 350)
                        ),
                        box(title = "Movies by Month", background = "black", solidHeader = TRUE, status = "primary", width= 12,
                            plotOutput("monthBarGraph", height = 350)
                        )
                    )
             ),
             column(4,
                    fluidRow(       
                      box(title = "Movies by Running Time", background = "black", solidHeader = TRUE, status = "primary", width= 12,
                          plotOutput("runTimeBarGraph", height = 350)
                      ),
                      box(title = "Movies by Certificate", background = "black", solidHeader = TRUE, status = "primary", width= 12,
                          plotOutput("certificateBarGraph", height = 350)
                      )
                    )
             ),
             column(4,
                    fluidRow(       
                      box(title = "Movies by Genre", background = "black", solidHeader = TRUE, status = "primary", width= 12,
                          plotOutput("genreBarGraph", height = 350)
                      ),
                      box(title = "Top N Keywords", background = "black", solidHeader = TRUE, status = "primary", width= 12,
                          plotOutput("keywordsBarGraph", height = 350)
                      )
                    )
             )
                     
                     
          ),
                
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
    ) # End fluid row
  ) # End dash board body

  
  
) # End dashboard page


# SERVER SIDE:
server <- function(input, output, session) {

  
  # REACTIVE FUNCTIONS:
  
  
  

  
  
  # BACKEND COMPONENTS:
  
  
  output$genreBarGraph <- renderPlot({
    
    ggplot(data=genres, aes(x=genre)) + 
      labs(x="Genre", y = "Number of Occurences") + 
      geom_bar(stat="count", width=0.7, fill="steelblue") +
      theme(axis.text.x=element_text(angle=55, hjust=1)) +
      scale_y_continuous(breaks= seq(0,150000,25000))
  }) # End bargraph3 
  
  
  
  
}#end server block

shinyApp(ui = ui, server = server)  #use ui and server in shiny app