library(tidyverse)
games <- read_csv("games.csv")
plays <- read_csv("plays.csv")
players <- read_csv("players.csv")

#This play is a duplicate.
plays <- plays[!(plays$gameId == 2021110100 &
                   plays$playId == 1267 & 
                   plays$absoluteYardlineNumber == 71), ]

week <- list()
for (i in 1:8) {
  print(i)
  week[[i]] <- read_csv(paste0("week", i, ".csv"))
  #merge on position
  week[[i]] <- merge(
    week[[i]],
    players[, c("nflId", "officialPosition")],
    by.x = "nflId",
    by.y = "nflId",
    all.x = TRUE
  )
  #merge on play outcome
  week[[i]] <- merge(
    week[[i]],
    plays[, c("gameId", "playId", "playResult")],
    by.x = c("gameId", "playId"),
    by.y = c("gameId", "playId"),
    all.x = TRUE
  )
  
  week[[i]]$y[week[[i]]$y > 160/3] <- 160/3
  week[[i]]$y[week[[i]]$y < 0] <- 0
  
  #convert all plays to be moving left
  week[[i]]$x[week[[i]]$playDirection == "right"] <-
    120 - week[[i]]$x[week[[i]]$playDirection == "right"]
  week[[i]]$y[week[[i]]$playDirection == "right"] <-
    160/3 - week[[i]]$y[week[[i]]$playDirection == "right"]
  week[[i]]
}


for (i in 1:length(week)) {
  week[[i]]$week <- i
}


track <- do.call(rbind, week)
track <-
  track[!duplicated(paste0(track$gameId, track$playId, track$nflId, track$frameId)), ]
#track[track$gameId == 2021110100 & track$playId == 1267,]

#Now pull out the QB rows and then merge that on.
qb <- track[track$officialPosition == "QB", ]
qb <- qb[!is.na(qb$gameId), ]
qb$key <- paste0(qb$gameId, "-", qb$playId)

#Remove plays with two QBs!
keys_2QB <- paste0(plays$gameId[grep("2 QB", plays$personnelO)], 
                   "-", 
                   plays$playId[grep("2 QB", plays$personnelO)])
qb <- qb[!(qb$key %in% keys_2QB), ]

qb <- qb[, c("gameId", "playId", "frameId", "x", "y", "s", "a", "dis", "o", "dir")]
names(qb)[4:10] <- paste0(names(qb)[4:10], "_", "QB")

merg <- merge(
  track,
  qb,
  by.x = c("gameId", "playId", "frameId"),
  by.y = c("gameId", "playId", "frameId"),
  all.x = TRUE
)
#remove 2 QB plays from tracking data
merg$key <- paste0(merg$gameId, "-", merg$playId)
merg <- merg[(!merg$key %in% keys_2QB), ]

#Distance from QB
merg <- merg |>
  mutate(distance_from_QB = sqrt((x - x_QB) ^ 2 + (y - y_QB) ^ 2))
#merg$distance_from_QB <- sqrt((merg$x - merg$x_QB)^2 + (merg$y - merg$y_QB)^2)

merg2 <- merg |>
  group_by(gameId, playId, nflId) |>
  group_modify( ~ {
    .x |> 
      arrange(frameId) |> 
      mutate(slope_distance_from_QB = c(NA, -diff(distance_from_QB)) / 0.1,
             strain = slope_distance_from_QB / distance_from_QB)
  }) |>
  mutate(acc_distance_from_QB = c(NA, -diff(slope_distance_from_QB)) / 0.1)


#Merge on players and plays
merg3 <- merge(
  merg2,
  plays[, c("gameId", "playId", "defensiveTeam")],
  by.x = c("gameId", "playId"),
  by.y = c("gameId", "playId"),
  all.x = TRUE
)

merg4 <- merge(
  merg3,
  players[, c("nflId", "displayName", "weight")],
  by.x = c("nflId"),
  by.y = c("nflId"),
  all.x = TRUE
)

#Merge on players and plays
merg3 <- merge(
  merg2,
  plays[, c("gameId", "playId", "defensiveTeam")],
  by.x = c("gameId", "playId"),
  by.y = c("gameId", "playId"),
  all.x = TRUE
)

merg4 <- merge(
  merg3,
  players[, c("nflId", "displayName", "weight")],
  by.x = c("nflId"),
  by.y = c("nflId"),
  all.x = TRUE
)

merg5 <- merg4|>
  group_by(gameId, playId) |>
  group_modify( ~ {
    .x|>
      mutate(snap_frame = .x$frameId[.x$event == "ball_snap"][1],
             end_frame = .x$frameId[.x$event %in% c("pass_forward", "qb_sack", "qb_strip_sack")][1])
  }) |>
  filter(frameId >= snap_frame & frameId <= end_frame) |> 
  mutate(frameId_snap_corrected = frameId - snap_frame + 1)

write_csv(merg5, "out.csv")