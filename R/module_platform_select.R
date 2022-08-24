# 
# simulation_params_ui <- function(id){
#   ns <- NS(id)
#   
#   inseason <- dplyr::between(lubridate::month(Sys.Date()), 2, 8)
#   
#   fluidRow(
#     column(
#       width = 2,
#       radioGroupButtons(
#         inputId = ns("platform"),
#         choices = c("MFL", "Sleeper","Fleaflicker","ESPN"),
#         selected = "MFL",
#         checkIcon = list("yes" = icon("check")),
#         status = "danger",
#         direction = "vertical",
#         justified = TRUE
#       )
#       ),
#     column(
#       width = 4,
#       textInput(
#         ns("league_id"),
#         label = NULL,
#         placeholder = "League ID"
#       ),
#       textInput(
#         ns("user_name"),
#         label = NULL,
#         placeholder = "Username (for private leagues)"
#       ),
#       passwordInput(
#         ns("password"),
#         label = NULL,
#         placeholder = "Password (for private leagues)"
#       ),
#       textInput(
#         ns("espn_s2"),
#         label = NULL,
#         placeholder = "ESPN S2 (for private leagues)"
#       ),
#       textInput(
#         ns("espn_swid"),
#         label = NULL,
#         placeholder = "ESPN SWID (for private leagues)"
#       ),
#     ),
#     column(
#       width = 6,
#       radioGroupButtons(
#         inputId = ns("actual_schedule"),
#         choices = c("Simulated Schedules", "Actual Schedules"),
#         selected = if(inseason) "Simulated Schedules" else "Actual Schedules",
#         checkIcon = list("yes" = icon("check")),
#         status = "danger",
#         justified = TRUE
#       ),
#       radioGroupButtons(
#         inputId = ns("best_ball"),
#         choices = c("Best Ball", "Lineups"),
#         selected = "Lineups",
#         checkIcon = list("yes" = icon("check")),
#         status = "danger",
#         justified = TRUE
#       ),
#       checkboxGroupButtons(
#         inputId = ns("pos_filter"),
#         choices =  c("QB","RB","WR","TE","K"),
#         selected =  c("QB","RB","WR","TE","K"),
#         checkIcon = list("yes" = icon("check")),
#         status = "danger",
#         justified = TRUE
#       )
#       
#     )
#   )
# }
# 
# simulation_params_server <- function(id){
# 
#   moduleServer(
#     id,
#     function(input,output,session){
#       ns <- session$ns
#       
#       observeEvent(input$platform,{
#         
#         if(input$platform == "MFL") {
#           shinyjs::show("user_name")
#           shinyjs::show("password")
#           shinjs::hide("espn_swid")
#           shinjs::hide("espn_s2")
#         }
#         if(input$platform == "Sleeper") {
#           shinyjs::hide("user_name")
#           shinyjs::hide("password")
#           shinjs::hide("espn_swid")
#           shinjs::hide("espn_s2")
#         }
#         if(input$platform == "ESPN") {
#           shinyjs::hide("user_name")
#           shinyjs::hide("password")
#           shinjs::show("espn_swid")
#           shinjs::show("espn_s2")
#         }
#         if(input$platform == "Fleaflicker") {
#           shinyjs::hide("user_name")
#           shinyjs::hide("password")
#           shinjs::hide("espn_swid")
#           shinjs::hide("espn_s2")
#         }
#         
#       })
#       
#     })
# }