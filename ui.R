
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
ui <- fluidPage(
  tags$head(
    tags$link(rel = 'stylesheet', type = 'text/css', href = 'custom.css')
  ),
  useShinyjs(),
  shinyjs::hidden(
    fluidRow(
      id = "step1",
      h1("What is the Goal?"),
      p("Any prioritization system must first establish the overall objective for the program.
        This requires defining the values that are important. In the context of imperiled species conservation, different people or groups may value extinction prevention more than cost savings (or vice-versa).
        As a result, species closest to the edge of extinction may be ranked higher than species closest to listing or delisting (or vice-versa) depending on values.
        Each prioritization scheme will assign weights to research projects based on the species' ranking."),
  br(),
  column(2,
         h2("Step 1:"),
         p("Choose a conservation goal. This will assign a score to the imperiled species in TX"),
         br(),
         selectInput(inputId = 'value', label = 'Prioritize Species to:', choices = list(
           "Prevent Extinction" = 'global_rank_2', 
           "Minimize Listing" = 'rpn',
           "Minimize Expenditures" = '1/total_exp',
           "Protect Ecosystems" = '1/Area'
           )
           ),
         br(),
         h2("Step 2:"),
         p("Select the study species by clicking the appropriate row on the table.",
           em("Note: Use the search box, or built-in column sorters to find your species.")
           )
  ),
  column(10,
         h4("Texas imperiled species"),
         dataTableOutput('rankedtable')
         )
  )
  ),
  
  shinyjs::hidden(
    fluidRow(
      id = "step2", width = '100%',
      h1("Describe the Research Project"),
      fluidRow(id = "panel2a", width = '100%',
      column(6,
             p("How will the research help prioritize conservation?",
               br(),
              "We determine the importance of research questions based on how they might inform a hypothetical 
               population viability model (shown at right).
              Ideally, research will direclty measure the effects of threats or conservation actions on the 
              probability of extinction - such that the most effective actions can be pursued in the future.",
              br(),
              "The following questions are designed to evaluate how directly proposed research will inform conservation actions."),
             br(),
             div(style = 'background-color: rgba(255, 127, 14, 0.3);
			  border-radius: 3px;
                          padding-top:10px;
                          padding-bottom:10px;
                          padding-right:10px;
                          padding-left:10px',
                 p(id='demo_note', em("Note: These questions and their weights are examples for demonstration.  The Texas CPA should come up with questions it thinks are most relevant to selecting research projects consistent with the CPA's goals."))
             )
      ),
      column(6, 
             tags$figure(class="figure",
                         tags$img(src="PVA.png", class="figure-img img-fluid rounded", alt="PVA model")
                         #tags$figcaption(class="figure-caption", "Population viability analysis model.")
             )
      )
      ),
      fluidRow(id = "panel2b", width = '100%',
               column(6,
                      h4(em(textOutput("proposed"))),
      radioButtons(
        inputId = "extinction", label = "...quantify the effect of conservation actions on extinction risk/probabilty of persistence?",
        choiceNames = list("Yes", "No"), choiceValues = list(50, 0), selected = (0), width = '100%'
      ),
      radioButtons(
        inputId = "demographics", label = "...measure demographic rates that can be used in population viability analyses (e.g. fecundity, surviviroship, etc.)?",
        choiceNames = list("Yes", "No"), choiceValues = list(20, 0), selected = (0), width = '100%'
      ),
      radioButtons(
        inputId = "threats", label = "...quantify the effect of one or more threats on demographic rate(s)?",
        choiceNames = list("Yes", "No"), choiceValues = list(30, 0), selected = (0),width = '100%'
      ),
      radioButtons(
        inputId = "actions", label = "...measure the effectiveness of actions for reducing threats?",
        choiceNames = list("Yes", "No"), choiceValues = list(20, 0), selected = (0),width = '100%'
      ),
      radioButtons(
        inputId = "outstanding", label = "...address an outstanding question identified in the species' recovery plan, five-year review, or listing rule?",
        choiceNames = list("Yes", "No"), choiceValues = list(10, 0), selected = (0),width = '100%'
      ),
      radioButtons(
        inputId = "estimates", label = "...include estimates of action costs and return on investment?",
        choiceNames = list("Yes", "No"), choiceValues = list(10, 0), selected = (0), width = '100%'
      ),
      div(style = 'background-color: rgba(31, 119, 180, 0.3);
          border-radius: 10px;
	  padding-top:10px;
          padding-bottom:10px;
          padding-left:10px',
          h4(em(textOutput('score')))
      )
    ),
    column(6,
           plotlyOutput('histo')
           )
    )
  )
  ),
  
  br(),
  fluidRow(
    id = 'actionButtons',
    actionButton("prevBtn", "< Previous"),
    actionButton("nextBtn", "Next >")
  )
)

#shinyApp(ui, server, options = list(height = 1080))
