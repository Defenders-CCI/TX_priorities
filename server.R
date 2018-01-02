
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

server <- function(input, output, session) {
  
  showModal(modalDialog(
    title = h2("Texas Imperlied Species Research Prioritization"),
    p("This interactive app demonstrates a framework developed by Defenders of Wildlife
      to help the Texas comptrollers office prioritize research projects, guiding a user through
      three key components:"),
    tags$ol(
      tags$li("Explicitly defining the conservation objectives"),
      tags$li("Ranking species based on these objectives"),
      tags$li("Scoring projects to maximize return  on investment")
      ),
    p("Begin by choosing a prioritiztion scheme, which will re-rank the imperiled species in Texas.
    Then select a hypothetical study species and click 'Next' to proceed."),
    easyClose = TRUE
  ))
  
  rv <- reactiveValues(page = 1)
  
  observe({
    shinyjs::toggleState(id = "prevBtn", condition = (rv$page > 1))
    shinyjs::toggleState(id = "nextBtn", condition = (rv$page < NUM_PAGES) & length(input$rankedtable_rows_selected)>0)
    shinyjs::hide(selector = ".row")
    shinyjs::show("actionButtons")
    shinyjs::show(paste0("step", rv$page))
    shinyjs::show(paste0("panel", rv$page, "a"))
    shinyjs::show(paste0("panel", rv$page, "b"))
  })
  
  
  navPage <- function(direction) {
    rv$page <- rv$page + direction
  }
  
  observeEvent(input$prevBtn, navPage(-1))
  observeEvent(input$nextBtn, navPage(1))
  
  makedf <- function(criteria){
    dplyr::select(TX_species, scientific_name, group, federal_status, rpn, global_rank_2, total_exp, Area)%>%
      dplyr::arrange_(criteria)%>%
      dplyr::mutate(Rank = seq(nrow(TX_species)), Weight = 1/c(rep(1:10, each = nrow(TX_species)%/%10), rep(10, nrow(TX_species)%%10)))%>%
      dplyr::arrange(scientific_name)
  }
  
  
  df <- reactive({makedf(input$value)})
  
  output$rankedtable <- renderDataTable(datatable(df(), selection = 'multiple',
                                        colnames = c("Species",
                                                    "Taxa",
                                                     "Federal Status",
                                                     "TX Status",
                                                     "Global Rank",
                                                     "Expenditures",
                                                     "Range Size (ac)",
                                                     "Rank",
                                                     "Weight")
                                        )%>%formatCurrency('total_exp')
  )
  
  spec <- reactive({df()[input$rankedtable_rows_selected, 'scientific_name']})
  weight <- reactive({df()[input$rankedtable_rows_selected, 'Weight']})
  output$proposed <- renderPrint({cat("Does the proposed research on ", spec(), "...",sep = "")})
  
  score <- reactive({
    sum(
      as.numeric(input$outstanding),
      as.numeric(input$estimates),
      as.numeric(input$threats),
      as.numeric(input$demographics),
      as.numeric(input$extinction),
      as.numeric(input$actions)
    )
  })
  
  rescore <- reactive({rescale(log(score()*weight()), to = c(0,1), from = c(0, log(max(possible$score))))})
  
  output$histo <- renderPlotly({
    plot_ly()%>%
      add_trace(type = 'scatter', mode = 'lines',
                x = ~c(rescore(), rescore()),
                y = c(0,500),
                name = 'Current Project')%>%
      add_trace(type = 'histogram', data = possible,
                x = ~rescale(log(score), c(0,1)), name = 'All Possible')%>%
      layout(legend = list(x = 0.7, y = 1),
             xaxis = list(title = "Project Score"),
             title = "Project ranking (Spp. weight * Research score)")
  })
  
  output$score <- renderPrint({cat("Total Research Score:", score()[1]/10, sep = " ")})
}
