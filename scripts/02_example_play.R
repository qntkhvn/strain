source("01_data_prep.R")

library(tidyverse)
library(gganimate)
library(magick)
library(ggtext)

# https://www.raiders.com/video/de-maxx-crosby-sacks-qb-teddy-bridgewater-for-a-loss-of-6-yards-nfl

plays <- read_csv("plays.csv")
desc <- plays |>
  filter(gameId == 2021101709 & playId == 1444) |>
  pull(playDescription) |> 
  str_replace("\\)\\.", "\\)")

play_lv_den <- merg5 |> 
  filter(gameId == 2021101709 & playId == 1444)

# player locations on the field
field <- ggplot()  +
  annotate("text", 
           x = seq(40, 80, 10),
           y = 10,
           color = "#bebebe",
           family = "Chivo",
           label = 10 * c(3:5, 4:3)) +
  annotate("text", 
           x = seq(40, 80, 10),
           y = 40,
           color = "#bebebe",
           family = "Chivo",
           label = 10 * c(3:5, 4:3)) +
  annotate("text", 
           x = setdiff(seq(35, 85, 1), seq(35, 85, 5)),
           y = -Inf,
           color = "#bebebe",
           label = "|") +
  annotate("text", 
           x = setdiff(seq(35, 85, 1), seq(35, 85, 5)),
           y = Inf,
           color = "#bebebe",
           label = "|") +
  annotate("text", 
           x = setdiff(seq(35, 85, 1), seq(35, 85, 5)),
           y = 23.36667,
           color = "#bebebe",
           label = "|") +
  annotate("text", 
           x = setdiff(seq(35, 85, 1), seq(35, 85, 5)),
           y = 29.96667,
           color = "#bebebe",
           label = "|") +
  annotate("segment", 
           x = 35,
           xend = 85,
           y = c(-Inf, Inf),
           yend = c(-Inf, Inf),
           color = "#bebebe") +
  geom_vline(xintercept = seq(35, 85, 5), color = "#bebebe") +
  geom_point(aes(x = x, y = y, size = strain),
             color = "black",
             data = filter(play_lv_den, team == "LV" & nflId != 47889)) +
  geom_point(aes(x = x, y = y, size = strain),
             color = "#1143E2",
             data = filter(play_lv_den, team == "LV" & nflId == 47889)) +
  geom_point(aes(x = x, y = y),
             color = "#FB4F14",
             data = filter(play_lv_den, team == "DEN")) +
  geom_point(aes(x = x, y = y),
             color = "#803621",
             shape = 20,
             data = filter(play_lv_den, team == "football")) +
  scale_size_area() +
  transition_states(frameId_snap_corrected,
                    wrap = FALSE,
                    transition_length = 2,
                    state_length = 1) +
  labs(title = "<span style = 'color:#000000;'>**Las Vegas Raiders**</span> @ <span style = 'color:#FB4F14;'>**Denver Broncos**</span>, 2021 NFL Week 6",
       subtitle = str_c("Q2: ", desc, "\n")) +
  theme_minimal() +
  theme(legend.position = "none",
        plot.subtitle = element_text(size = 9, face = "italic", hjust = 0.5),
        plot.title = element_markdown(hjust = 0.5, size = 12),
        text = element_text(family = "Chivo", color = "#26282A"),
        axis.text = element_blank(),
        panel.grid = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank())

# maxx crosby
mc <- play_lv_den |> 
  ungroup() |> 
  filter(nflId == 47889) |>
  select(frameId_snap_corrected, distance_from_QB, slope_distance_from_QB, strain)

indiv <- mc |> 
  pivot_longer(!frameId_snap_corrected) |> 
  mutate(
    name = case_when(
      name == "distance_from_QB" ~ "Distance from QB (yards)",
      name == "slope_distance_from_QB" ~ "Velocity (yards/second)",
      name == "strain" ~ "STRAIN (1/second)"
    ),
    name = fct_relevel(name, "STRAIN (1/second)", after = Inf)
  ) |> 
  ggplot() +
  geom_line(aes(frameId_snap_corrected, value, color = name), linewidth = 1) +
  geom_point(data = mc, aes(frameId_snap_corrected, strain, size = strain)) +
  labs(x = "Time since snap (seconds)",
       y = "\n\n\n\n\nFeature value") +
  scale_x_continuous(breaks = seq(0, 40, 10), labels = 0:4) +
  scale_color_manual(values = c("gray", "#FFCC33" , "#1143E2"),
                     guide = guide_legend(order = 1)) +
  labs(color = NULL,
       size = "STRAIN",
       title = "<span style = 'color:#1143E2;'>**M. Crosby**</span> throughout the play") +
  theme_light() +
  theme(plot.title = element_markdown(size = 10),
        axis.title = element_text(size = 9),
        legend.text = element_text(size = 9),
        legend.title = element_text(size = 9.5),
        text = element_text(family = "Chivo", color = "#26282A")) +
  transition_reveal(frameId_snap_corrected)


# combine animations
field_anim <- animate(
  field,
  width = 600,
  height = 290,
  nframes = 120,
  fps = 20,
  end_pause = 12,
  res = 100
)
indiv_anim <- animate(
  indiv,
  width = 540,
  height = 280,
  nframes = 70,
  fps = 10,
  end_pause = 5,
  res = 100
)
field_gif <- image_read(field_anim)
indiv_gif <- image_read(indiv_anim)

comb_gif <- image_append(c(field_gif[1], indiv_gif[1]), stack = TRUE)
for(i in 2:65){
  combined <- image_append(c(field_gif[i], indiv_gif[i]), stack = TRUE)
  comb_gif <- c(comb_gif, combined)
}
comb_gif
