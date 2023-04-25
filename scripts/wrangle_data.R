library("tidyverse")
library("rvest")
library("magrittr")
library("here")

genres <- c("Action", "Action-Adventure", "Adventure", "Board Game", "Education", "Fighting", "Misc", "MMO", "Music", "Party", "Platform", "Puzzle", "Racing", "Role-Playing", "Sandbox", "Shooter", "Simulation", "Sports", "Strategy", "Visual Novel")
month_key <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

# Load data from multiple csv
load_add_genre <- function(genre) {
  path <- paste("data/raw/", genre %>% str_replace_all(" ", "_"), ".csv", sep = "")
  readfile <- read.csv(path, skip = 2) %>%
    mutate("Genre" = genre) %>%
    subset(select = -`Box.Art`)
  readfile
}

# Create a master list, combine dfs
master <- tibble()
for(genre in genres) {
  raw_list <- genre %>% load_add_genre()
  master %<>% bind_rows(raw_list)
}

# Remove "Read the review" from Title
master$Game %<>% str_replace_all("    Read the review", "")
# Replace "N/A" with actual NA val
master[2:17] %<>% mutate_all(~na_if(., "N/A"))
# Strip m from counts, convert to ints, put factor in title
master[9:14] %<>% mutate_all(~str_replace_all(., "m", "") %>% as.numeric())
# Combine Total.Sales and Total.Shipped into one column - mutually exclusive
master$Total.Units <- ifelse(!is.na(master$Total.Shipped) & !is.na(master$Total.Sales), 
                             NA, 
                             ifelse(!is.na(master$Total.Shipped), 
                                    master$Total.Shipped, 
                                    master$Total.Sales))
# Split dates into m d y
master %<>% mutate("Release.Year" = Release.Date %>% parse_year()) %>% 
  mutate("Release.Month" = Release.Date %>% parse_month()) %>%
  mutate("Release.Day" = Release.Date %>% parse_day()) %>%
  mutate("Updated.Year" = Last.Update %>% parse_year()) %>% 
  mutate("Updated.Month" = Last.Update %>% parse_month()) %>%
  mutate("Updated.Day" = Last.Update %>% parse_day()) %>%
  # Remove unnecessary columns
  subset(select = -c(`Release.Date`, `Last.Update`, `Total.Sales`, `Total.Shipped`))
# Rename Total.Units (combined) to Total.Sales for consistency
colnames(master)[colnames(master)=="Total.Units"] <- "Total.Sales"

# Reorder columns logically
master <-master[, c("Pos", "Game", "Console", "Genre", "Publisher", "Developer", "Total.Sales", "NA.Sales", "PAL.Sales", "Japan.Sales", "Other.Sales", "Release.Year", "Release.Month", "Release.Day", "VGChartz.Score", "Critic.Score", "User.Score", "Updated.Year", "Updated.Month", "Updated.Day")] 

write.csv(master, file = "data/wrangled/vgchartz_full.csv")
save(master, file = here("data", "wrangled", "wrangled_data.rda"))

#=================
# Function Definitions
parse_year <- function(date) {
  years <- date %>% substr(10, 11) %>% as.numeric()
  for (i in seq_along(years)) {
    if(is.na(years[i])) {
      # Do nothing
    }
    else if(years[i] >= 50)
      years[i] <- years[i] + 1900
    else
      years[i] <- years[i] + 2000
  }
  years
}

parse_month <- function(date) {
  months <- date %>% substr(6, 8)
  for (i in seq_along(months)) {
    month_id <- match(months[i], month_key)
    if(!is.na(month_id)) {
      months[i] = month_id
    }
  } 
  months %>% as.numeric()
}

parse_day <- function(date) {
  date %>% substr(1,2) %>% as.numeric()
}