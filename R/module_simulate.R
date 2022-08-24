
simulate_ui <- function(id){
  
  ns <- NS(id)
  
  inseason <- dplyr::between(lubridate::month(Sys.Date()), 2, 8)
  
  tabItem(
    tabName = id,
    dp_box(
      id = ns("setup_box"),
      title = paste("Simulation Setup:", id),
      fluidRow(
        column(
          width = 12,
          radioGroupButtons(
            inputId = ns("platform"),
            choices = c("MFL", "Sleeper","Fleaflicker","ESPN"),
            selected = "MFL",
            checkIcon = list("yes" = icon("check")),
            status = "danger",
            # direction = "vertical",
            justified = TRUE
          )
        )
      ),
      fluidRow(
        column(
          width = 4,
          textInput(
            ns("league_id"),
            label = NULL,
            placeholder = "League ID"
          )
        ),
        column(
          width = 4,
          textInput(
            ns("user_name"),
            label = NULL,
            placeholder = "Username (for private leagues)"
          ) |> shinyjs::hidden(),
          textInput(
            ns("espn_s2"),
            label = NULL,
            placeholder = "ESPN S2 (for private leagues)"
          )|> shinyjs::hidden()
        ),
        column(
          width = 4,
          passwordInput(
            ns("password"),
            label = NULL,
            placeholder = "Password (for private leagues)"
          )|> shinyjs::hidden(),
          textInput(
            ns("espn_swid"),
            label = NULL,
            placeholder = "ESPN SWID (for private leagues)"
          )|> shinyjs::hidden()
        ),
      ),
      br(),
      fluidRow(
        column(
          width = 12,
          tags$details(
            tags$summary("More Options"),
            br(),
            fluidRow(
              # style = "text-align: center !important;",
              column(
                width = 3,
                radioGroupButtons(
                  inputId = ns("actual_schedule"),
                  choices = c("Simulated Schedules", "Actual Schedules"),
                  selected = if(inseason) "Simulated Schedules" else "Actual Schedules",
                  checkIcon = list("yes" = icon("check")),
                  status = "danger"
                  # justified = TRUE
                )
              ),
              column(
                width = 3,
                radioGroupButtons(
                  inputId = ns("best_ball"),
                  choices = c("Best Ball", "Lineups"),
                  selected = "Lineups",
                  checkIcon = list("yes" = icon("check")),
                  status = "danger"
                  # justified = TRUE
                )
              ),
              column(
                width = 6,
                checkboxGroupButtons(
                  inputId = ns("pos_filter"),
                  choices =  c("QB","RB","WR","TE","K"),
                  selected =  c("QB","RB","WR","TE","K"),
                  checkIcon = list("yes" = icon("check")),
                  status = "danger"
                  # justified = TRUE
                )
              )
            )
          )
        )
      ),
      footer = div(
        actionButton(ns("run_simulation"), "Run Simulation!", status = "primary"),
        style = "text-align:center;")
    ),
    uiOutput(ns("plot_box"))
  )
}

simulate_server <- function(id){
  
  moduleServer(
    id,
    function(input, output, session){
      # simulation_params_server("params")
      
      ns <- session$ns
      
      observeEvent(input$platform,{
        
        if(input$platform == "MFL") {
          shinyjs::show("user_name")
          shinyjs::show("password")
          shinyjs::hide("espn_swid")
          shinyjs::hide("espn_s2")
        }
        if(input$platform == "Sleeper") {
          shinyjs::hide("user_name")
          shinyjs::hide("password")
          shinyjs::hide("espn_swid")
          shinyjs::hide("espn_s2")
        }
        if(input$platform == "ESPN") {
          shinyjs::hide("user_name")
          shinyjs::hide("password")
          shinyjs::show("espn_swid")
          shinyjs::show("espn_s2")
        }
        if(input$platform == "Fleaflicker") {
          shinyjs::hide("user_name")
          shinyjs::hide("password")
          shinyjs::hide("espn_swid")
          shinyjs::hide("espn_s2")
        }
      })
      
      sim_data <- eventReactive(input$run_simulation,{
        
        req(input$league_id)
        # shinyjs::hide("run_simulation")
        bs4Dash::updateBox("setup_box", action = "remove")
        waiter::waiter_show(html = spin_dots(),color = transparent(0.5))
        on.exit(waiter::waiter_hide())
        
        conn <- suppressMessages(ffscrapr::ff_connect(
          platform = tolower(input$platform),
          league_id = input$league_id,
          user_name = if(input$user_name!= "") input$user_name,
          password = if(input$password != "") input$password,
          espn_s2 = if(input$espn_s2 != "") input$espn_s2,
          espn_swid = if(input$espn_swid != "") input$espn_swid
        ))
        
        if(id == "Season"){
          simulation <- ffsimulator::ff_simulate(
            conn = conn,
            n_seasons = 50,
            n_weeks = 14,
            best_ball = input$best_ball == "Best Ball",
            actual_schedule = input$actual_schedule == "Actual Schedules",
            verbose = FALSE,
            pos_filter = input$pos_filter
          )
        }
        
        if(id == "UpcomingWeek"){
          simulation <- ffsimulator::ff_simulate_week(
            conn = conn,
            n = 100,
            best_ball = input$best_ball == "Best Ball",
            actual_schedule = input$actual_schedule == "Actual Schedules",
            verbose = FALSE,
            pos_filter = input$pos_filter
          )
        }
        
        # bs4Dash::updateBox("setup_box", action = "remove")
        
        return(simulation)
      })
      
      output$plot_box <- renderUI({
        
        req(sim_data())
        
        available_plots <- if(id == "Season") c("Wins", "Rank", "Points") else c("Luck", "Points")
        
        dp_box(
          title = "Simulation Results",
          fluidRow(
            column(
              3,
              radioGroupButtons(
                inputId = ns("plot_type"),
                choices = available_plots,
                selected = available_plots[[1]],
                checkIcon = list("yes" = icon("check")),
                status = "danger",
                justified = TRUE)
            ),
            column(9,
                   downloadButton(ns("download_simulation"), "Download Simulation!"),
                   actionButton(ns("reset"), "Reset", status = "danger")
            )
          ),
          br(),
          # column(8,
          fluidRow(
            plotOutput(ns("plots"))
          )
        )
        
      })
      
      output$plots <- renderPlot({
        req(sim_data())
        req(input$plot_type)
        
        plot(sim_data(), type = tolower(input$plot_type))
      })
      
      output$download_simulation <- downloadHandler(
        filename = "Simulation.xlsx",
        content = function(file){
          
          export_data <- sim_data()
          class(export_data) <- "list"
          export_data$simulation_params <- export_data$simulation_params |> 
            tibble::enframe() |> 
            dplyr::mutate(value = purrr::map_chr(value,paste, collapse = "; "))
          
          writexl::write_xlsx(
            x = export_data,
            path = file,
            col_names = TRUE,
            format_headers = TRUE)
        }
      )
      
      observeEvent(input$reset, session$reload())
      
      
    }
  )
  
}