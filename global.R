library(dplyr)
library(DT)
library(plotly)
library(scales)
library(shiny)
library(shinyjs)
library(shinyBS)

county_data <- readRDS(file = "data/US_counties_attrib.rds")
counties <- readRDS(file = 'data/ESA_counties_2017-12-27.rds')
load("data/data.RData")
TX_species$common_name <- as.character(TX_species$common_name)
TX_species$scientific_name <- as.character(TX_species$scientific_name)
TX_species$federal_status <- factor(TX_species$federal_status,
                                    levels = c("Not listed",
                                               "Delisted",
                                               "Proposed Threatened",
                                               "Proposed Endangered",
                                               "Candidate",
                                               "Endangered, Proposed for Delisting",
                                               "Threatened",
                                               "Endangered"))
TX_species$rpn <- factor(TX_species$rpn, levels = c("1", "1C",
                                                    "2", "2C",
                                                    "3", "3C",
                                                    "7", "7C",
                                                    "8", "8C",
                                                    "9", "9C",
                                                    "13", "13C",
                                                    "4", "4C",
                                                    "5", "5C",
                                                    "6", "6C",
                                                    "10", "10C",
                                                    "11", "11C",
                                                    "12", "12C",
                                                    "14", "UNK", ""))
counties$county_fips <- as.numeric(counties$county_fips)

county_sums <- select(county_data, GEOID, ALAND)%>%
  right_join(counties, by = c("GEOID" = "county_fips"))%>%
  filter(state_name == 'Texas')%>%
  group_by(scientific_name, common_name)%>%
  summarise(area = sum(ALAND))

TX_species$Area <- unlist(lapply(1:nrow(TX_species), function(x){
  area <- ifelse(TX_species$scientific_name[x] %in% county_sums$scientific_name,
                 county_sums$area[county_sums$scientific_name == TX_species$scientific_name[x]],
                 ifelse(TX_species$common_name[x] %in% county_sums$common_name,
                        county_sums$area[county_sums$common_name == TX_species$common_name[x]], NA))
  return(area)
})
)

TX_species <- left_join(TX_species, county_sums, by = "scientific_name")

possible <- expand.grid(1/(1:nrow(TX_species)),
                        c(50,0), c(20,0), c(20,0), c(10,0), c(10,0), c(30,0))%>%
  dplyr::mutate(score = Var1*(Var2+Var3+Var4+Var5+Var6+Var7))

NUM_PAGES <- 2