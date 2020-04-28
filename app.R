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
library(lubridate)
library(DT)
library(dplyr)

#IMPORTANT: app.R needs "dark_theme_mod.R" in the same directory to run well with the dark theme:
#source("dark_theme_mod.R") #connectz

#NOTE: the data file to be read here is first processed by our Python scripts.
#READ IN THE DATA FILES:

certificates <- read.csv(file = "csvFiles/final_csvFiles/certificates-cleaned-final.csv",sep=",", header= TRUE)
genres <- read.csv(file="csvFiles/final_csvFiles/genres-cleaned-final.csv",sep=",", header=TRUE)
keywords <- read.csv(file="csvFiles/final_csvFiles/keywords-movies-cleaned-final.csv",sep=",", header=TRUE)
movies <- read.csv(file="csvFiles/final_csvFiles/movies-cleaned-final.csv",sep=",",header=TRUE)
releaseDates <- read.csv(file="csvFiles/final_csvFiles/release-dates-cleaned-final.csv",sep=",",header=TRUE)
runningTimes <- read.csv(file="csvFiles/final_csvFiles/running-times-cleaned-final.csv",sep=",")[c(2:6)]


# convert string date into r-format date

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

# function
# gets movie from releaseDates within a decade
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


averageMoviesPerYear = as.integer(mean(moviesPerYear$title))


getGenreByYear <- function(uYear){
  genresTemp <- genres[genres$year.produced == uYear,]
  genresTemp <- genresTemp[,c("genre","title")]
  genresTemp <- aggregate(. ~genre, genresTemp, length)
  genresTemp
}

getGenreByDecade <- function(uYear){
  decadeVar = floor(uYear/10)*10
  genresTemp <- genres[as.numeric(as.character(genres$year.produced)) > uYear,]
  genresTemp <- genresTemp[as.numeric(as.character(genresTemp$year.produced)) <= uYear+10,]
  genresTemp <- genresTemp[,c("genre","title")]
  genresTemp <- aggregate(. ~genre, genresTemp, length)
  genresTemp
}

#filter out remaining bad genre types:
genres <- genres[genres$genre != 'Adult',]
genres <- genres[genres$genre != 'Short',]
genres <- genres[genres$genre != 'Reality-TV',]
genres <- genres[genres$genre != 'Talk-Show',]
genres <- genres[genres$genre != 'Game-Show',]
genres <- genres[genres$genre != 'News',]
#gets genres total
genresOr <- genres[,c("genre","title")]
genresOr <- aggregate(. ~genre, genresOr, length)
genresOr$all <- TRUE


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

runningTimes$timerange[runningTimes$time.min <= 69] <- '60-69'
runningTimes$timerange[runningTimes$time.min >=70 & runningTimes$time.min <=79] <- '70-79'
runningTimes$timerange[runningTimes$time.min >=80 & runningTimes$time.min <=89] <- '80-89'
runningTimes$timerange[runningTimes$time.min >=90 & runningTimes$time.min <=99] <- '90-99'
runningTimes$timerange[runningTimes$time.min >=100 & runningTimes$time.min <=109] <- '100-109'
runningTimes$timerange[runningTimes$time.min >=110 & runningTimes$time.min <=119] <- '110-119'
runningTimes$timerange[runningTimes$time.min >=120 & runningTimes$time.min <=129] <- '120-129'
runningTimes$timerange[runningTimes$time.min >=130] <- '130+'

averageRunningTime = as.integer(mean(runningTimes$time.min))
maxRunningTime = max(runningTimes$time.min)/60



#SHINY DASHBOARD:

ui <- dashboardPage(
  
  #Header
  dashboardHeader(title = "Movies Dashboard"),
  
  #Sidebar
  dashboardSidebar(disable = FALSE, collapsed = FALSE,
                   
                   #insert inputs here
                   selectInput("chooseDecade","Choose a decade",append("all",seq(1890,2030,by=10)), selected="all"),
                   selectInput("chooseYear","Choose a year",append("all",yearRange[,1]), selected="all"),
                   sliderInput("keywordsSlider", "Amount of keywords to show:",
                               min = 5, max = 20,
                               value = 5)
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
                            box(title = "Movies by Year", background = "black", solidHeader = TRUE, status = "primary", width= 12, height = 410,
                                tabsetPanel(
                                  tabPanel("Chart", plotOutput("yearBarGraph", height = "300px")),
                                  tabPanel("Table", dataTableOutput("yearTable", height = 250)),
                                  tabPanel("Stats", infoBoxOutput("averageYearInfoBox", width = 80))
                                )
                            ),
                            box(title = "Movies by Month", background = "black", solidHeader = TRUE, status = "primary", width= 12, height = 410,
                                tabsetPanel(
                                  tabPanel("Chart", plotOutput("monthBarGraph", height = "300px")),
                                  tabPanel("Table", dataTableOutput("monthTable", height = 250))
                                )
                            )
                          )
                   ),
                   column(4,
                          fluidRow(       
                            box(title = "Movies by Running Time", background = "black", solidHeader = TRUE, status = "primary", width= 12, height = 410,
                                tabsetPanel(
                                  tabPanel("Chart", plotOutput("runtimeBarGraph", height = "300px")),
                                  tabPanel("Table", dataTableOutput("runtimeTable", height = 250)),
                                  tabPanel("Stats", 
                                           fluidRow(
                                                    infoBoxOutput("averageRuntimeInfoBox", width = 80),
                                                    infoBoxOutput("maxRuntimeInfoBox", width = 80)
                                           )
                                           
                                  )
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
                            box(title = "Top Keywords", background = "black", solidHeader = TRUE, status = "primary", width= 12, height = 410,
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
                   h4("Project 3 in CS 424 (Data Analytics / Visualization) at the University of Illinois at Chicago, Spring 2020"),
                   h5("________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________"),
                   h5("This project is an interactive visualization of the information related to genres and plot keywords in films over 100 years. You can overview a single year, or a decade.
                             You also have the ability to look at a graphical reprentation or tabular version of your selections. Additionally, you can see data of running times, genres, and the top number 'N'
                             keywords. Lastly, you can see all of this data side by side to adequatley analyze the data"),
                   h5("________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________"),
                   h5("Note: This project implements an interactive display/analysis of a dataset of films released in the United States dating back several years. Movie ratings have changed over
                             the years and therefore, it is suggested that you keep this in mind when analyzing the trends of movies with respect to their ratings over the years.
                             For effiency purposes, some TV episodes, video game/ internet enteries, movies that don't have a year, ratings with Short, Adult, Reality-TV, Talk Show, Game Show, etc.. "),                   
                   h5("There are about 22 genres to view and analyze in this visualization."),
                   h5("________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________"),
                   h5("________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________"),
                   h5("Here is a list of the certificates in the USA: "),
                   h5("G (General Audiences) - All ages admitted."),
                   h5("PG (Parental Guidance Suggested) - Some material may not be suitable for children."),
                   h5("PG-13 (Parents Strongly Cautioned) - Some material may be inappropriate for children under 13."),
                   h5("R (Restricted) - Under 17 requires accompanying parent or adult guardian."),
                   h5("NC-17 (Adults Only) - No one 17 and under admitted."),
                   h5("________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________"),
                   h5("________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________________"),
                   h5("* Libraries Used: shiny, shinydashboard, devtools, dashboardthemes, ggplot2, lubridate, DT, dplyr"),
                   h5("* Files Used: release-dates.list, running-times.list, certificates.list, genres.list, keywords.list, movies.list, ratings.list"),
                   h5("* Data Source: IMDB Movie Database ->ftp://ftp.fu-berlin.de/pub/misc/movies/database/frozendata/ "),
                   h5("* Created using R, RStudio, Shiny, Python, theme: https://github.com/nik01010/dashboardthemes")
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
  
  #year bar graph
  output$yearBarGraph <- renderPlot({
    ggplot(data=moviesPerYear, aes(x=year,y=title)) +
      geom_bar(stat="identity")
  })
  
  #month bar graph
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
  
  #genre bar graph
  output$genreBarGraph <- renderPlot({
    
    if(input$chooseDecade == "all" && input$chooseYear == "all"){
      genresTemp <- genresOr
    }
    else if(input$chooseDecade !="all"){
      genresTemp <- getGenreByDecade(as.numeric(input$chooseDecade))
    }
    else{
      genresTemp <- getGenreByYear(as.numeric(input$chooseDecade))
    }
    
    positions <- c('Drama','Comedy','Documentary','Romance','Action','Thriller','Crime','Horror','Adventure',
                   'Family','Mystery','Fantasy','Biography',
                   'History','Musical','War','Sci-Fi','Music','Animation','Western','Sport','Film-Noir')
    
    genresTemp <- full_join(genresTemp,genresOr)
    ggplot(data=genresTemp, aes(x=genre,y=title,fill=all))+
      geom_col(position = "dodge")
    #ggplot(data=genres, aes(x=genre)) + 
     # labs(x="Genre", y = "Number of Movies") +
      #geom_bar(stat="count", width=0.7, fill="navy") +
      #scale_x_discrete(limits = positions) +
      #theme(axis.text.x=element_text(angle=55, hjust=1)) +
      #theme(text = element_text(size = 16))  +
      #theme(plot.background = element_rect(fill = "white")) +
      #theme(panel.background = element_rect(fill = "gray85",linetype = "solid")) +
      #scale_y_continuous(breaks= seq(0,150000,25000))
  }) # End genre bar graph
  
  
  #keywords bargraph
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
    
  })
  
  
  #certificate bar graph
  output$certificateBarGraph <- renderPlot({
    positions <- c('Approved', 'Passed', 'GP', 'R', 'PG', 'PG-13', 'G')
    
    ggplot(data=certificates, aes(x=rating, fill=factor(era))) + 
      labs(x="Rating", y = "Number of Movies") +
      geom_bar(stat="count", width=0.7) +
      scale_x_discrete(limits = positions) +
      scale_fill_manual(values=c('#917047','darkorange'), name="time frame", labels = c("pre-1960s", "post-1960s")) +
      theme(axis.text.x=element_text(angle=55, hjust=1)) +
      theme(text = element_text(size = 16))  +
      theme(plot.background = element_rect(fill = "white")) +
      theme(panel.background = element_rect(fill = "gray85",linetype = "solid")) +
      scale_y_continuous(breaks= seq(0,10000,2000))
  })  
  
  
  #running time bar graph
  output$runtimeBarGraph <- renderPlot({
    
    positions <- c('60-69', '70-79', '80-89', '90-99', '100-109', '110-119', '120-129', '130+')

    ggplot(data=runningTimes, aes(x=timerange)) + 
      labs(x="Running Time (min)", y = "Number of Movies") +
      geom_bar(stat="count", width=0.7, fill="darkgreen") +
      scale_x_discrete(limits = positions) +
      theme(axis.text.x=element_text(angle=55, hjust=1)) +
      theme(text = element_text(size = 16))  +
      theme(plot.background = element_rect(fill = "white")) +
      theme(panel.background = element_rect(fill = "gray85",linetype = "solid")) #+
      #scale_y_continuous(breaks= seq(0,150000,25000))
  })
  
  
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
  
  output$certificateTable <- DT::renderDataTable(
    
    DT::datatable({
      certificates[c(1,2,4)]
    },
    options = list(searching = FALSE, pageLength = 5, lengthChange = FALSE), 
    rownames = FALSE
    )
  )
  
  output$runtimeTable <- DT::renderDataTable(
    
    DT::datatable({
      runningTimes[c(1,2,4)]
    },
    options = list(searching = FALSE, pageLength = 5, lengthChange = FALSE), 
    rownames = FALSE
    )
  )
  
  output$yearTable <- DT::renderDataTable(
    
    DT::datatable({
      releaseDates[c(2:5)]
    },
    options = list(searching = FALSE, pageLength = 5, lengthChange = FALSE), 
    rownames = FALSE
    )
  )
  
  output$monthTable <- DT::renderDataTable(
    
    DT::datatable({
      moviesPerMonthOr[c(1:2)]
    },
    options = list(searching = FALSE, pageLength = 6, lengthChange = FALSE), 
    rownames = FALSE
    )
  )
  
  #infoboxes:
  output$averageRuntimeInfoBox <- renderInfoBox({
    infoBox(
      "Average", paste0(averageRunningTime, " minutes"), icon = icon("clock"), color = "green"
    )
  })
  
  output$maxRuntimeInfoBox <- renderInfoBox({
    infoBox(
      "Max", paste0(maxRunningTime, " hours"), icon = icon("clock"), color = "green"
    )
  })
  
  
  output$averageYearInfoBox <- renderInfoBox({
    infoBox(
      "Average", paste0(averageMoviesPerYear, " movies per year"), icon = icon("calendar"), color = "black"
    )
  })
  
  
  
}#end server block


shinyApp(ui = ui, server = server)  #use ui and server in shiny app