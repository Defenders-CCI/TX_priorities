
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(dplyr)
library(DT)
library(shiny)
library(shinyjs)
library(shinyBS)

load("data/data.rdata")

NUM_PAGES <- 5

ui <- fluidPage(
  useShinyjs(),
  shinyjs::hidden(
    lapply(seq(NUM_PAGES), function(i) {
      div(
        class = "page",
        id = paste0("step", i),
        "Step", i
      )
    })
  ),
  br(),
  selectInput(inputId = 'value', label = 'Prioritization/nScheme', choices = list(
    "Prevent Extinction" = 'global_rank_2', 
    "Minimize Listing" = 'federal_status',
    "Minimize Expenditures" = 'total_exp',
    "Protect Ecosystems" = 'plan_date'
  )),
  br(),
  verbatimTextOutput('species'),
  dataTableOutput('rankedtable'),
  br(),
  actionButton("prevBtn", "< Previous"),
  actionButton("nextBtn", "Next >")
)

server <- function(input, output, session) {
  rv <- reactiveValues(page = 1)
  
  observe({
    shinyjs::toggleState(id = "prevBtn", condition = rv$page > 1)
    shinyjs::toggleState(id = "nextBtn", condition = rv$page < NUM_PAGES)
    shinyjs::hide(selector = ".page")
    shinyjs::show(paste0("step", rv$page))
  })
  
  
  navPage <- function(direction) {
    rv$page <- rv$page + direction
  }
  
  observeEvent(input$prevBtn, navPage(-1))
  observeEvent(input$nextBtn, navPage(1))
  
  makedf <- function(criteria){
    dplyr::arrange_(TX_species, criteria)#%>%
    #dplyr::mutate(Rank = rep(1:5, each = nrow(TX_species)/5), Weight = 1/Rank)
  }
  
  output$rankedtable <- renderDataTable(makedf(input$value), selection = 'multiple')
  
  species <- reactiveValues()
  observeEvent(input$rankedtable_rows_selected,
               {rows <- input$rankedtable_rows_selected
               species <- TX_species$scientific_name[rows]}
  )
  output$species <- renderPrint({paste(species)})
}

shinyApp(ui, server)
