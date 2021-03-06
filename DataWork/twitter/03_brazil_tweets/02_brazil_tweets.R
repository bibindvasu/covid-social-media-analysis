# Restrict Tweets to Those in Brazil 

# Make Brazil Regex Search -----------------------------------------------------
brazil_adm3 <- readRDS(file.path(dropbox_file_path, "Data", "GADM", "RawData", "gadm36_BRA_3_sp.rds"))
brazil_cities <- readRDS(file.path(dropbox_file_path, "Data", "city_population", "FinalData", "brazil_cities_pop_wikipedia.Rds"))

brazil_cities <- brazil_cities %>%
  arrange(desc(estimate_2018)) %>%
  head(50) 

#### Make Search Regex
brazil_search <- c("brazil", "brasil",
                   brazil_adm3$NAME_1 %>% unique(),
                   brazil_cities$City) %>%
  tolower() %>%
  str_squish() %>%
  unique()

#brazil_search <- c("brazil", "brasil")

brazil_search_wordbounds <- paste0("\\b", brazil_search, "\\b") %>% paste(collapse = "|")
brazil_search_nowordbounds <- brazil_search %>% paste(collapse = "|")

# Load Data --------------------------------------------------------------------
file_names <- list.files(file.path(dropbox_file_path, "Data", "twitter", "RawData", "rds"), pattern = "*.Rds")

temp <- lapply(file_names, function(file_name_i){
  
  print(file_name_i)
  
  #### Check if file already cleaned
  file_already_exists <- file.exists(file.path(dropbox_file_path, "Data", "twitter", "IntermediateData", "brazil_tweets", "rds", paste0("brazil_", file_name_i)))
  
  if(file_already_exists %in% F){
    #### Load
    tweets_df <- readRDS(file.path(dropbox_file_path, "Data", "twitter", "RawData", "rds", file_name_i))
    
    #### Restrict to Brazil
    tweets_df <- tweets_df %>%
      mutate(location = location %>% tolower %>% str_squish()) %>%
      mutate(brazil = grepl(brazil_search_wordbounds, location) | grepl(brazil_search_wordbounds, full_text)) %>%
      filter(brazil %in% T) %>% 
      dplyr::select(-brazil)
    
    #### Save
    #print(nrow(tweets_df))
    saveRDS(tweets_df, file.path(dropbox_file_path, "Data", "twitter", "IntermediateData", "brazil_tweets", "rds", paste0("brazil_", file_name_i)))
  }
  
})



