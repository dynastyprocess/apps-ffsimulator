cache <- cachem::cache_disk(here::here("cache"))
app_latest_rankings <- memoise::memoise(ffsimulator::ffs_latest_rankings, cache = cache,~ memoise::timeout(43200))
app_rosters <- memoise::memoise(ffsimulator::ffs_rosters, cache = cache, ~ memoise::timeout(43200))
app_franchises <- memoise::memoise(ffsimulator::ffs_franchises, cache = cache, ~ memoise::timeout(604800))
app_starter_positions <- memoise::memoise(ffsimulator::ffs_starter_positions, cache = cache, ~memoise::timeout(604800))

conn <- ffsimulator::mfl_connect(2021,54040)

ff_simulate_app <- function(conn, # user-edited
                            n_seasons = 100, 
                            n_weeks = 14,
                            best_ball = FALSE, # user-edited
                            seed = NULL, 
                            gp_model = c("simple", "none"), # user-edited
                            base_seasons = 2012:2020,
                            actual_schedule = FALSE,
                            pos_filter = c("QB","RB","WR","TE","K"), # user-edited
                            verbose = FALSE) {
  
  gp_model <- match.arg(gp_model)
  
  #### Import Data ####
  
  league_info <- ffscrapr::ff_league(conn)
  scoring_history <- ffscrapr::ff_scoringhistory(conn, base_seasons)
  
  latest_rankings <- app_latest_rankings(type = "draft")
  franchises <- app_franchises(conn)
  rosters <- app_rosters(conn)
  lineup_constraints <- app_starter_positions(conn)
  weeks <- seq_len(n_weeks)
  
  #### Generate Projections ####
  
  adp_outcomes <- ffsimulator::ffs_adp_outcomes(
    scoring_history = scoring_history,
    gp_model = gp_model,
    pos_filter = pos_filter
  )
  
  projected_scores <- ffsimulator::ffs_generate_projections(
    adp_outcomes = adp_outcomes,
    latest_rankings = latest_rankings,
    n_seasons = n_seasons,
    weeks = weeks,
    rosters = rosters
  )
  
  #### Calculate Roster Scores ####
  
  roster_scores <- ffsimulator::ffs_score_rosters(
    projected_scores = projected_scores,
    rosters = rosters
  )
  
  optimal_scores <- ffsimulator::ffs_optimise_lineups(
    roster_scores = roster_scores,
    lineup_constraints = lineup_constraints,
    best_ball = best_ball,
    pos_filter = pos_filter
  )
  
  #### Generate Schedules ####
  
    schedules <- ffsimulator::ffs_build_schedules(
      n_seasons = n_seasons,
      n_weeks = n_weeks,
      franchises = franchises
    )
  
  #### Summarise Season ####
  
  summary_week <- ffsimulator::ffs_summarise_week(optimal_scores, schedules)
  summary_season <- ffsimulator::ffs_summarise_season(summary_week)
  summary_simulation <- ffsimulator::ffs_summarise_simulation(summary_season)
  
  #### Build and Return ####
  
  out <- structure(
    list(
      summary_simulation = summary_simulation,
      summary_season = summary_season,
      summary_week = summary_week,
      roster_scores = roster_scores,
      projected_scores = projected_scores,
      league_info = league_info,
      simulation_params = list(
        n_seasons = n_seasons,
        n_weeks = n_weeks,
        scrape_date = latest_rankings$scrape_date[[1]],
        best_ball = best_ball,
        seed = seed,
        gp_model = gp_model,
        actual_schedule = actual_schedule,
        base_seasons = list(base_seasons),
        pos_filter = list(pos_filter)
      )
    ),
    class = "ff_simulation"
  )
  
  return(out)
}
