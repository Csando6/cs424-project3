#+
#--app.R file for Project 3 of CS 424 - Group 4-------
#-----------------------------------------------------
#--Amber Little------*********************************
#--Charly Sandoval---*********************************
#--Matt Jankowski----*********************************
#-----------------------------------------------------

library(shiny)
library(shinydashboard)
#library(devtools)        #for theme
#library(dashboardthemes) #for theme
library(ggplot2)
library(lubridate)
library(DT)


#IMPORTANT: app.R needs "dark_theme_mod.R" in the same directory to run well with the dark theme:
#source("dark_theme_mod.R") #connectz

#NOTE: the data file to be read here is first processed by our Python scripts.
#READ IN THE DATA FILES:

#certificates <- read.csv(file = "csvFiles/final_csvFiles/certificates-cleaned-final.csv",sep=",", header= TRUE)
genres <- read.csv(file="csvFiles/final_csvFiles/genres-cleaned-final.csv",sep=",", header=TRUE)

keywords <- read.csv(file="csvFiles/final_csvFiles/keywords-movies-cleaned-final.csv",sep=",", header=TRUE)
movies <- read.csv(file="csvFiles/final_csvFiles/movies-cleaned-final.csv",sep=",",header=TRUE)
releaseDates <- read.csv(file="csvFiles/final_csvFiles/release-dates-cleaned-final.csv",sep=",",header=TRUE)
runningTimes <- read.csv(file="csvFiles/final_csvFiles/running-times-cleaned-final.csv",sep=",")
 

## convert string date into r-format date
releaseDates$date.released <- dmy(releaseDates$date.released)

moviesPerYear <- movies[,c('year','title')]
moviesPerYear <- aggregate(. ~year, moviesPerYear, length)
moviesPerYear <- moviesPerYear[moviesPerYear$title > 100,]

moviesPerMonth <- releaseDates[,c('date.released','title')]
moviesPerMonth$date.released <- month(moviesPerMonth$date.released) 
moviesPerMonthOr <- aggregate(. ~date.released, moviesPerMonth, length)
moviesPerMonthOr$all <- TRUE

yearRange <- releaseDates[,c('date.released',"title")]
yearRange$date.released <- year(yearRange$date.released)
yearRange <- aggregate(. ~date.released, yearRange, length)
yearRange[1]

## function
## gets movie from releaseDates within a decade
getMovieByDecade <- function(year){
  decadeVar = floor(year/10)*10
  releaseD <- releaseDates[,c('date.released','title')]
  releaseD <- releaseD[year(releaseD$date.released) > year,]
  releaseD <- releaseD[year(releaseD$date.released) < year+10,]
  releaseD$date.released <- month(releaseD$date.released)
  releaseD <- aggregate(. ~date.released, releaseD, length)
  releaseD
}

## get function by year
getMovieByYear <- function(year){
 releaseD <- releaseDates[,c('date.released','title')]
 releaseD <- releaseD[year(releaseD$date.released) == year,]
 releaseD$date.released <- month(releaseD$date.released)
 releaseD <- aggregate(. ~date.released, releaseD, length)
 releaseD
}

#filter out remaining bad genre types:
genres <- genres[genres$genre != 'Adult',]
genres <- genres[genres$genre != 'Short',]
genres <- genres[genres$genre != 'Reality-TV',]
genres <- genres[genres$genre != 'Talk-Show',]
genres <- genres[genres$genre != 'Game-Show',]
genres <- genres[genres$genre != 'News',]


#keywords by frequency:
keywordsFreq <-as.data.frame(table(keywords$keyword))
keywordsFreq <- keywordsFreq[order(-keywordsFreq$Freq),]
colnames(keywordsFreq) = c('keyword', 'frequency')



#certificates:
certificates <- certificates[certificates$rating != '(Banned)',]
certificates <- certificates[certificates$rating != '12',]
certificates <- certificates[certificates$rating != 'AO',]
certificates <- certificates[certificates$rating != 'GA',]
certificates <- certificates[certificates$rating != 'Open',]

#era column: 1 = pre-1968 scale, 2 = post-1968 scale (with some exceptions)
certificates$era[certificates$rating == 'Approved'] <- 1
certificates$era[certificates$rating == 'Passed'] <- 1
certificates$era[certificates$rating == 'GP'] <- 1
certificates$era[certificates$rating == 'R'] <- 2
certificates$era[certificates$rating == 'PG'] <- 2
certificates$era[certificates$rating == 'PG-13'] <- 2
certificates$era[certificates$rating == 'G'] <- 2

#certificates:
certificates <- certificates[certificates$rating != '(Banned)',]
certificates <- certificates[certificates$rating != '12',]
certificates <- certificates[certificates$rating != 'AO',]
certificates <- certificates[certificates$rating != 'GA',]
certificates <- certificates[certificates$rating != 'Open',]

#era column: 1 = pre-1968 scale, 2 = post-1968 scale (with some exceptions)
certificates$era[certificates$rating == 'Approved'] <- 1
certificates$era[certificates$rating == 'Passed'] <- 1
certificates$era[certificates$rating == 'GP'] <- 1
certificates$era[certificates$rating == 'R'] <- 2
certificates$era[certificates$rating == 'PG'] <- 2
certificates$era[certificates$rating == 'PG-13'] <- 2
certificates$era[certificates$rating == 'G'] <- 2


#SHINY DASHBOARD:

ui <- dashboardPage(
  
  #Header
  dashboardHeader(title = "Saturday Night at the Movies"),
  
  #Sidebar
  dashboardSidebar(disable = FALSE, collapsed = FALSE,
                   
                   #insert inputs here
                   selectInput("chooseDecade","Choose a decage",append("all",seq(1890,2030,by=10)), selected="all"),
                   selectInput("chooseYear","Choose a year",append("all",yearRange[,1]), selected="all"),  
                   
                   sliderInput("keywordsSlider", "Show top N Keywords:",
                               min = 5, max = 20,
                               value = 5)
  ),
  
  #Body
  dashboardBody(
    
    #dark_theme_mod,  # dark theme
    
    
    
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
                            box(title = "Movies by Running Time", background = "black", solidHeader = TRUE, status = "primary", width= 12, height = 410,
                                tabsetPanel(
                                  tabPanel("Chart", plotOutput("runtimeBarGraph", height = "300px")),
                                  tabPanel("Table", dataTableOutput("gruntimeTable", height = 250))
                                )
                            ),
                            box(title = "Movies by Certificate (USA)", background = "black", solidHeader = TRUE, status = "primary", width= 12, height = 410,
                                tabsetPanel(
                                  tabPanel("Chart", plotOutput("certificateBarGraph", height = "300px")),
                                  tabPanel("Table", dataTableOutput("certificateTable", height = 250))
                                )
                            )
                          )
                   ),
                   column(4,
                          fluidRow(       
                            box(title = "Movies by Genre", background = "black", solidHeader = TRUE, status = "primary", width= 12, height = 410,
                                tabsetPanel(
                                     tabPanel("Chart", plotOutput("genreBarGraph", height = "300px")),
                                     tabPanel("Table", dataTableOutput("genreTable", height = 250))
                                )
                            ),
                            box(title = "Top N Keywords", background = "black", solidHeader = TRUE, status = "primary", width= 12, height = 410,
                                tabsetPanel(
                                  tabPanel("Chart", plotOutput("keywordsBarGraph", height = "300px")),
                                  tabPanel("Table", dataTableOutput("keywordsTable", height = 250))
                                )
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
  
  topNkeywordsDF <- reactive(
    head(keywordsFreq, n = input$keywordsSlider)
  ) #contatins just the data about selected picker
  
  
  
  # BACKEND COMPONENTS:
  
  output$yearBarGraph <- renderPlot({
    ggplot(data=moviesPerYear, aes(x=year,y=title)) +
      geom_bar(stat="identity")
  })
  
  output$monthBarGraph <- renderPlot({
    #print(input$chooseDecade)
    if(input$chooseDecade == "all" && input$chooseYear == "all"){
      moviesPerMonth <- moviesPerMonthOr
    }
    else if(input$chooseDecade !="all"){
      moviesPerMonth <- getMovieByDecade(as.numeric(input$chooseDecade) )
      moviesPerMonth <- full_join(moviesPerMonth, moviesPerMonthOr)
    }
    else{
      moviesPerMonth <- getMovieByYear(as.numeric(input$chooseYear) )
      moviesPerMonth <- full_join(moviesPerMonth, moviesPerMonthOr)
    }
    ggplot(data=moviesPerMonth, aes(x=date.released,y=title,fill=all)) +
      geom_col(position = "dodge")
    
  })
  
  
  output$genreBarGraph <- renderPlot({
    
    positions <- c('Drama','Comedy','Documentary','Romance','Action','Thriller','Crime','Horror','Adventure',
                   'Family','Mystery','Fantasy','Biography',
                   'History','Musical','War','Sci-Fi','Music','Animation','Western','Sport','Film-Noir')
    
    ggplot(data=genres, aes(x=genre)) + 
      labs(x="Genre", y = "Number of Movies") +
      geom_bar(stat="count", width=0.7, fill="navy") +
      scale_x_discrete(limits = positions) +
      theme(axis.text.x=element_text(angle=55, hjust=1)) +
      theme(text = element_text(size = 16))  +
      theme(plot.background = element_rect(fill = "white")) +
      theme(panel.background = element_rect(fill = "gray85",linetype = "solid")) +
      scale_y_continuous(breaks= seq(0,150000,25000))
  }) # End genre bar graph
  
  
  output$keywordsBarGraph <- renderPlot({
    
    topNkeywordsDF <- topNkeywordsDF()
    
    ggplot(data=topNkeywordsDF, aes(x=reorder(keyword, -frequency), y=frequency)) + 
      labs(x="Keyword", y = "Number of Movies") +
      geom_bar(stat="identity", width=0.7, fill="darkred") +
      theme(axis.text.x=element_text(angle=45, hjust=1)) +
      theme(text = element_text(size = 16))  + 
      theme(plot.background = element_rect(fill = "white")) +
      theme(panel.background = element_rect(fill = "gray85",linetype = "solid")) +
      scale_y_continuous(breaks= seq(0,15000,5000))
    
  }) # End keywords bargraph
  
  
  output$certificateBarGraph <- renderPlot({
    positions <- c('Approved', 'Passed', 'GP', 'R', 'PG', 'PG-13', 'G')
    
    ggplot(data=certificates, aes(x=rating, fill=factor(era))) + 
      labs(x="Rating", y = "Number of Movies") +
      geom_bar(stat="count", width=0.7) +
      scale_x_discrete(limits = positions) +
      scale_fill_manual(values=c('#b0926d','darkorange'), name="time frame", labels = c("pre-1970s", "post-1970s")) +
      theme(axis.text.x=element_text(angle=55, hjust=1)) +
      theme(text = element_text(size = 16))  +
      theme(plot.background = element_rect(fill = "white")) +
      theme(panel.background = element_rect(fill = "gray85",linetype = "solid")) +
      scale_y_continuous(breaks= seq(0,10000,2000))
  }) # End genre bar graph  
  
  #tables:

  output$genreTable <- DT::renderDataTable(
    
    DT::datatable({
      genres[c(2:4)]
    },
    options = list(searching = FALSE, pageLength = 5, lengthChange = FALSE), 
    rownames = FALSE
    )
  )
  
  output$keywordsTable <- DT::renderDataTable(
    
    DT::datatable({
      topNkeywordsDF <- topNkeywordsDF()
    },
    options = list(searching = TRUE, pageLength = 5, lengthChange = FALSE), 
    rownames = FALSE
    )
  )
}#end server block


shinyApp(ui = ui, server = server)  #use ui and server in shiny app