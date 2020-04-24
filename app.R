library(shiny)
library(shinydashboard)

certificate <- read.csv(file = "csvFiles/certificates-cleaned.csv",sep="\t", header= TRUE)
genres <- read.csv(file="csvFiles/genres-cleaned.csv",sep="\t", header=TRUE)
keyWordKey <- read.csv(file="csvFiles/keywords-keys-cleaned.csv",sep=",", header=TRUE)
keyWordMovie <- read.csv(file="csvFiles/keywords-movies-cleaned.csv",sep=",", header=TRUE)
movie <- read.csv(file="csvFiles/movies-cleaned.csv",sep="\t",header=TRUE)
releaseDate <- read.csv(file="csvFiles/release-dates-cleaned.csv",sep="\t",header=TRUE)
runningTimes <- read.csv(file="csvFiles/running-times-cleaned.csv",sep="\t")

########### Front-end ###########
ui <- dashboardPage(
      dashboardHeader(title="project3"),
      dashboardSidebar(disable=FALSE,collapsed = FALSE),
      dashboardBody()
)

########### Back-end ###########
server <- function(input, output){
  
}

########### Init-App ###########
shinyApp(ui=ui, server=server)