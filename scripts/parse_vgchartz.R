library("tidyverse")
library("rvest")
library("magrittr")
library("here")

genres <- c("Action", "Action-Adventure", "Adventure", "Board Game", "Education", "Fighting", "Misc", "MMO", "Music", "Party", "Platform", "Puzzle", "Racing", "Role-Playing", "Sandbox", "Shooter", "Simulation", "Sports", "Strategy", "Visual Novel")
month_key <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

# Function Definitions
load_add_genre <- function(genre) {
  path <- paste("data/raw/", genre %>% str_replace_all(" ", "_"), ".csv", sep = "")
  readfile <- read.csv(path, skip = 2) %>%
    mutate("Genre" = genre) %>%
    subset(select = -`Box.Art`)
  readfile
}

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

clean_names <- function(names) {
  names %>% str_replace_all("1C Company", "1C Maddox Games") %>%
    # 2K Games subsidiaries
    str_replace_all("2K Play", "2K Games") %>%
    str_replace_all("2K Sports", "2K Games") %>%
    str_replace_all("989 Sports", "989 Studios") %>%
    # ASCII Media Works merger
    str_replace_all("ASCII Entertainment", "ASCII Media Works") %>%
    str_replace_all("Media Works", "ASCII Media Works") %>%
    # Activision subsidiaries
    str_replace_all("Activision Blizzard", "Activision") %>%
    str_replace_all("Activision Value", "Activision") %>%
    # Bandai Namco merger
    str_replace_all("Bandai Namco Entertainment", "Bandai Namco") %>%
    str_replace_all("Bandai Namco Games", "Bandai Namco") %>%
    str_replace_all("Bandai Visual", "Bandai Namco") %>%
    str_replace_all("Namco", "Bandai Namco") %>%
    str_replace_all("Namco Bandai", "Bandai Namco") %>%
    str_replace_all("Namco Bandai Games", "Bandai Namco") %>%
    str_replace_all("Namco Networks America Inc.", "Bandai Namco") %>%
    # More solos
    str_replace_all("CD Projekt Red Studio", "CD Projekt Red") %>%
    str_replace_all("Capcom Entertainment", "Capcom") %>%
    str_replace_all("Coffee Stain Publishing", "Coffee Stain Studios") %>%
    str_replace_all("D3Publisher", "D3 Publisher") %>%
    str_replace_all("Daedalic Entertainment", "Daedalic") %>%
    str_replace_all("Double Fine Presents", "Double Fine Productions") %>%
    str_replace_all("Eidos Interactive Ltd", "Eidos Interactive") %>%
    str_replace_all("Excalibur Publishing Limited", "Excalibur Publishing") %>%
    # EA subsidiaries
    str_replace_all("EA Sports", "Electronic Arts") %>%
    str_replace_all("EA Sports BIG", "Electronic Arts") %>%
    # Nihon Falcom 
    str_replace_all("Falcom", "Nihon Falcom") %>%
    str_replace_all("Falcom Corporation", "Nihon Falcom") %>%
    str_replace_all("Nihon Falcom Corp", "Nihon Falcom") %>%
    str_replace_all("Nihon Falcom Corporation", "Nihon Falcom") %>%
    # Focus
    str_replace_all("Focus Home Interactive", "Focus") %>%
    str_replace_all("Focus Multimedia", "Focus") %>%
    str_replace_all("Game Factory Interactive", "Game Factory") %>%
    str_replace_all("Gearbox Publishing", "Gearbox Software") %>%
    str_replace_all("Hudson Entertainment", "Hudson Soft") %>%
    str_replace_all("Idea Factory International", "Idea Factory Interactive") %>%
    str_replace_all("Infocom, Inc.", "Infocom") %>%
    # Interchannel (Initially NEC subsidiary, then NEC left market)
    str_replace_all("Interchannel-Holon", "Interchannel") %>% # Last market name
    str_replace_all("NEC Interchannel", "Interchannel") %>%
    str_replace_all("NEC Avenue", "Interchannel") %>%
    str_replace_all("NEC", "Interchannel") %>%  
    str_replace_all("Interchannel", "Interchannel-Holon") %>% # Put it back
    # Interplay
    str_replace_all("Interplay Entertainment Corp.", "Interplay") %>%
    str_replace_all("Interplay Productions", "Interplay") %>%
    # Koei Tecmo Merger
    str_replace_all("KOEI", "Koei Tecmo") %>%
    str_replace_all("Tecmo", "Koei Tecmo") %>%
    str_replace_all("Tecmo Koei", "Koei Tecmo") %>%
    str_replace_all("Koei Koei Tecmo", "Koei Tecmo") %>% # Clean up prev calls
    str_replace_all("Tecmo Tecmo Koei", "Koei Tecmo") %>%
    # Solos
    str_replace_all("Kadokawa Games", "Kadokawa Shoten") %>%
    str_replace_all("Kalypso Media", "Kalypso") %>%
    str_replace_all("Konami Digital Entertainment", "Konami") %>%
    str_replace_all("MLB.com", "MLB Advanced Media") %>%
    str_replace_all("Majesco Entertainment", "Majesco") %>%
    # Marvelous acquirement
    str_replace_all("Marvelous Entertainment", "Marvelous") %>%
    str_replace_all("Marvelous Interactive", "Marvelous") %>%
    str_replace_all("AQ Interactive", "Marvelous") %>%
    # Mattel
    str_replace_all("Mattel Electronics", "Mattel") %>%
    str_replace_all("Mattel Interactive", "Mattel") %>%
    str_replace_all("Mattel Media", "Mattel") %>%
    # Mircrosoft / Xbox
    str_replace_all("Microsoft Game Studios", "Microsoft") %>%
    str_replace_all("Microsoft Studios", "Microsoft") %>%
    str_replace_all("Xbox Game Studios", "Microsoft") %>%
    # Solos
    str_replace_all("Maximum Family Games", "Maximum Games") %>%
    str_replace_all("Midway Games", "Midway") %>%
    str_replace_all("Milestone S.r.l", "Milestone") %>%
    str_replace_all("Milestone S.r.l.", "Milestone") %>%
    str_replace_all("NeocoreGames", "Neocore Games") %>%
    str_replace_all("NIS America", "Nippon Ichi Software") %>%
    str_replace_all("O~3 Entertainment", "O3 Entertainment") %>%
    str_replace_all("Ocean Software", "Ocean") %>%
    str_replace_all("Otomate Idea Factory", "Otomate") %>%
    str_replace_all("Paradox Development", "Paradox Interactive") %>%
    str_replace_all("Parker Bros.", "Parker Brothers") %>%
    # Sony / Playstation
    str_replace_all("PlayStation Mobile Inc.", "Sony") %>%
    str_replace_all("PlayStation PC", "Sony") %>%
    str_replace_all("Sony Computer Entertainment America", "Sony") %>%
    str_replace_all("Sony Computer Entertainment Europe", "Sony") %>%
    str_replace_all("Sony Computer Entertainment", "Sony") %>%
    str_replace_all("Sony Imagesoft", "Sony") %>%
    str_replace_all("Sony Interactive Entertainment", "Sony") %>%
    str_replace_all("Sony Music Entertainment", "Sony") %>%
    str_replace_all("Sony Online Entertainment", "Sony") %>%
    # Solo
    str_replace_all("Polytron Corporation", "Polytron") %>%
    str_replace_all("Psyonix Studios", "Psyonix") %>%
    str_replace_all("Rebellion Developments", "Rebellion") %>%
    str_replace_all("Rebellion Games", "Rebellion") %>%
    str_replace_all("Red Orb Entertainment", "Red Orb") %>%
    str_replace_all("Rising Star Games", "Rising Star") %>%
    str_replace_all("Sierra Studios", "Sierra") %>%
    str_replace_all("Sierra Online", "Sierra") %>%
    str_replace_all("Sierra Entertainment", "Sierra") %>%
    str_replace_all("SNK Playmore", "SNK") %>%
    str_replace_all("SouthPeak Interactive", "SouthPeak Games") %>%
    # Spike Chunsoft merger
    str_replace_all("Chunsoft", "Spike Chunsoft") %>%
    str_replace_all("Spike", "Spike Chunsoft") %>%
    str_replace_all("Spike Spike Chunsoft", "Spike Chunsoft") %>%
    str_replace_all("Spike Chunsoft Chunsoft", "Spike Chunsoft") %>%
    # Square Enix merger
    str_replace_all("Square EA", "Square Enix") %>%
    str_replace_all("SquareSoft", "Square Enix") %>%
    str_replace_all("Crystal Dynamics", "Square Enix") %>%
    str_replace_all("Enix", "Square Enix") %>%
    str_replace_all("Square", "Square Enix") %>%
    str_replace_all("Square Square Enix", "Square Enix") %>%
    str_replace_all("Square Enix Enix", "Square Enix") %>%
    str_replace_all("Summitsoft Entertainment", "Summitsoft") %>%
    str_replace_all("System 3 Arcade Software", "System 3") %>%
    # System Soft
    str_replace_all("SystemSoft", "System Soft") %>%
    str_replace_all("SystemSoft Alpha", "System Soft") %>%
    str_replace_all("System Soft Alpha", "System Soft") %>%
    # Takara Tomy
    str_replace_all("Tomy Corporation", "Takara Tomy") %>%
    str_replace_all("Takara", "Takara Tomy") %>%
    str_replace_all("Takara Tomy Tomy", "Takara Tomy") %>%
    str_replace_all("TDK Core", "TDK") %>%
    str_replace_all("TDK Mediactive", "TDK") %>%
    # Team17
    str_replace_all("Team 17", "Team17") %>%
    str_replace_all("Team17 Digital Ltd", "Team17") %>%
    str_replace_all("Team17 Software", "Team17") %>%
    str_replace_all("THQ Nordic", "THQ") %>%
    # Warner
    str_replace_all("Time Warner Interactive", "Warner Bros") %>%
    str_replace_all("Warner Bros. Interactive Entertainment", "Warner Bros") %>%
    str_replace_all("Warner Bros. Interactive", "Warner Bros") %>%
    # Valve
    str_replace_all("Valve Software", "Valve") %>%
    str_replace_all("Valve Corporation", "Valve") %>%
    # Virgin Interactive
    str_replace_all("Virgin Play", "Virgin Interactive") %>%
    str_replace_all("Virgin Games", "Virgin Interactive") %>%
    # WayForward
    str_replace_all("WayForward Technologies", "WayForward") %>%
    str_replace_all("Way Forward", "WayForward") %>%
    # Solo
    str_replace_all("TopWare Interactive", "TopWare") %>%
    str_replace_all("Zoo Games silver", "indiePub") %>%
    str_replace_all("Zoo Games", "indiePub") %>%
    str_replace_all("Zoo Digital Publishing", "Zushi Games")
}

