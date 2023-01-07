source("01_data_prep.R")

library(tidyverse)
library(gt)

pff <- read_csv("pffScoutingData.csv")

pass_rush_only <- merg5 |> 
  left_join(pff) |>
  filter(pff_role == "Pass Rush")

test <- pass_rush_only |> 
  filter(team == defensiveTeam & !is.na(strain))
# test$distance_from_QB[test$distance_from_QB < 0.1] <- 0.1
test$strain <- test$slope_distance_from_QB/test$distance_from_QB
test_summed <- test |> 
  group_by(nflId) |>
  summarize(
    strain = sum(strain),
    name = head(displayName, 1),
    pos = head(officialPosition, 1),
    n = n(),
    n_plays = length(unique(playId))
  ) |>
  mutate(strain_rate = 10 * strain / n) |> 
  arrange(-strain_rate) |> 
  ungroup()

info <- test |> 
  ungroup() |> 
  select(nflId, team, displayName, officialPosition) |> 
  distinct()

out <- test_summed |> 
  left_join(info, by = "nflId") |> 
  filter(n_plays >= 100 & !is.infinite(strain)) |> 
  mutate(rank = row_number()) |> 
  filter(strain_rate > 0) |> 
  select(rank, displayName, 
         officialPosition,
         team, 
         n_plays, 
         strain, 
         strain_rate)

# edge rushersedge <- out |>  filter(officialPosition %in% c("OLB", "DE")) |>   mutate(rank = row_number()) |>   select(rank, displayName, team, officialPosition, n_plays, strain_rate) |>   head(20) |>   gt() |>  tab_options(    table.border.top.color = "white",    row.striping.include_table_body = FALSE  ) |>  opt_table_font(    font = list(      google_font("Chivo"),      default_fonts()    )  ) |>  fmt_number(    columns = c(strain_rate),    decimals = 2,  ) |>  data_color(    columns = c(strain_rate),    colors = scales::col_numeric(      palette = c("#FEE0D2", "#67000D"),      domain = NULL    )  ) |>   cols_label(    rank = md("**Rank**"),    displayName = md("**Player**"),    team = md("**Team**"),    officialPosition = md("**Position**"),    n_plays = md("**Total Plays**"),    strain_rate = html('<span style="text-decoration:overline; font-weight:bold">STRAIN</span>')  ) |>   cols_align(    align = "center",    columns = n_plays:strain_rate  ) |>   tab_header(md("**Top 20 Edge Rushers**"),             md("(Minimum 100 plays)")) |>   tab_style(style = cell_borders(sides = "top"),            locations = cells_title("title")) |>   tab_options(    table.border.top.style = "a"  ) |>   tab_footnote(    footnote = "Average STRAIN across all frames played",    locations = cells_column_labels(      columns = strain_rate    )  )gtsave(edge, "edge.png")# interiorinterior <- out |>  filter(officialPosition %in% c("DT", "NT")) |>   mutate(rank = row_number()) |>   select(rank, displayName, team, officialPosition, n_plays, strain_rate) |>   head(20) |>   gt() |>  tab_options(    table.border.top.color = "white",    row.striping.include_table_body = FALSE  ) |>  opt_table_font(    font = list(      google_font("Chivo"),      default_fonts()    )  ) |>  fmt_number(    columns = c(strain_rate),    decimals = 2,  ) |>  data_color(    columns = c(strain_rate),    colors = scales::col_numeric(      palette = c("#DEEBF7", "#08306B"),      domain = NULL    )  ) |>   cols_label(    rank = md("**Rank**"),    displayName = md("**Player**"),    team = md("**Team**"),    officialPosition = md("**Position**"),    n_plays = md("**Total Plays**"),    strain_rate = html('<span style="text-decoration:overline; font-weight:bold">STRAIN</span>')  ) |>   cols_align(    align = "center",    columns = n_plays:strain_rate  ) |>   tab_header(md("**Top 20 Interior Rushers**"),             md("(Minimum 100 plays)")) |>   tab_style(style = cell_borders(sides = "top"),            locations = cells_title("title")) |>   tab_options(    table.border.top.style = "a"  ) |>   tab_footnote(    footnote = "Average STRAIN across all frames played",    locations = cells_column_labels(      columns = strain_rate    )  )gtsave(interior, "interior.png")

# combine tables
library(magick)
image_append(c(image_read("edge.png"), image_read("interior.png")))
