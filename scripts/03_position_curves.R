source("01_data_prep.R")

pff <- read_csv("pffScoutingData.csv")

pass_rush_only <- merg5 |> 
  left_join(pff) |>
  filter(pff_role == "Pass Rush")

avg <- pass_rush_only |> 
  filter(team == defensiveTeam,
         frameId_snap_corrected <= 40) |> 
  group_by(frameId_snap_corrected) |> 
  summarise(mn = mean(strain, na.rm = TRUE))
  

pass_rush_only |> 
  filter(team == defensiveTeam,
         officialPosition %in% c("OLB", "NT", "DE", "DT"),
         frameId_snap_corrected <= 40) |> 
  group_by(officialPosition, frameId_snap_corrected) |> 
  summarise(mn = mean(strain, na.rm = TRUE)) |> 
  bind_rows(mutate(avg, officialPosition = "Average")) |> 
  mutate(officialPosition = factor(officialPosition, levels = c("OLB", "DE", "DT", "NT", "Average"))) |> 
  ggplot(aes(frameId_snap_corrected, mn, 
             color = officialPosition, 
             group = officialPosition, 
             linetype = officialPosition)) +
  geom_smooth(se = FALSE, span = 0.3, linewidth = 1.2) +
  scale_color_manual(values = c("#D81B60", "#1E88E5", "#FFC107", "#004D40", "gray"), name = "Position") +
  scale_x_continuous(breaks = seq(0, 40, 10), labels = 0:4) +
  scale_linetype_manual(values = c(rep("solid", 4), "dotted"), name = "Position") +
  labs(y = "STRAIN",
       x = "Time since snap (seconds)") +
  theme_light() +
  theme(text = element_text(family = "Chivo", color = "#26282A"),
        legend.key.width = unit(1.02, "cm"))
