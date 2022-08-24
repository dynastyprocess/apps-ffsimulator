
suppressPackageStartupMessages({

  # Data Import
  library(arrow)

  # Data Manipulation
  # library(tidyverse)
  library(dplyr)
  library(purrr)
  # library(tidyr)
  library(glue)
  # library(magrittr)
  # library(janitor)
  # library(lubridate)
  # library(hrbrthemes)
  # hrbrthemes::import_plex_sans()

  # Shiny libraries
  library(shiny)
  library(bs4Dash)
  library(shinyjs)
  library(shinyWidgets)
  library(DT)
  # library(reactable)
  # library(joker) # tanho63/joker
  library(waiter)
  library(sever)
  library(ragg)
  #library(ggiraph)
  # library(details)

  # Report libraries
  library(writexl)

  options(shiny.reactlog = TRUE)
  options(stringsAsFactors = FALSE)
  options(scipen = 999)
  options(dplyr.summarise.inform = FALSE)
  options(shiny.useragg = TRUE)
  
  # extrafont::loadfonts()
})
