pkgload::load_all()

ui <- dashboardPage(
  dark = NULL,
  title = "ffsimulator | DynastyProcess.com",
  # sidebar_collapsed = TRUE,
  header = dp_header(
    glue::glue("DP.com: ffsimulator v{packageVersion('ffsimulator')}")
  ),
  sidebar = dp_sidebar(
    menuItem("Season", tabName = "Season", icon = icon("quidditch")),
    menuItem("Upcoming Week", tabName = "UpcomingWeek", icon = icon("bolt")),
    debug = FALSE),
  body = dashboardBody(
    useShinyjs(),
    use_sever(),
    use_waiter(),
    # waiter_on_busy(),
    dp_cssjs(),
    tabItems(
      simulate_ui("Season"),
      simulate_ui("UpcomingWeek")
    )
  ) # end of body ----
) # end of UI ----

# Server ----
server <- function(input, output, session) {
  
  sever_dp()
  
  # observeEvent(input$debug, browser())
  
  simulate_server("UpcomingWeek")
  simulate_server("Season")
  
} # end of server ####

shinyApp(ui, server)
