library(shiny)
library(shinydashboard)

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