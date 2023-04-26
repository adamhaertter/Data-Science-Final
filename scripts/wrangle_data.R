library("tidyverse")
library("rvest")
library("magrittr")
library("here")

# Import function definitions from separate file
source("scripts/parse_vgchartz.R")

# Load data from multiple csv, combine to master list
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
# Make a column for common publisher names
master$Publisher.Simple <- master$Publisher %>% clean_names()

# Reorder columns logically
master <-master[, c("Pos", "Game", "Console", "Genre", "Publisher.Simple", "Publisher", "Developer", "Total.Sales", "NA.Sales", "PAL.Sales", "Japan.Sales", "Other.Sales", "Release.Year", "Release.Month", "Release.Day", "VGChartz.Score", "Critic.Score", "User.Score", "Updated.Year", "Updated.Month", "Updated.Day")] 

write.csv(master, file = "data/wrangled/vgchartz_full.csv")
save(master, file = here("data", "wrangled", "wrangled_data.rda"))
