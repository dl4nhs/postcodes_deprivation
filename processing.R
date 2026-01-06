library(tidyverse)
library(here)

## ---- processing


#data from: https://open-geography-portalx-ons.hub.arcgis.com/datasets/b8451168e985446eb8269328615dec62/about
#Postcode to OA (2021) to LSOA to MSOA to LAD (August 2024) Best Fit Lookup in the UK
postcodes_raw <- read_csv(here::here("input", "PCD_OA21_LSOA21_MSOA21_LAD_AUG24_UK_LU.csv")) |> 
  mutate(dointr = lubridate::ym(dointr)) |> 
  mutate(doterm = lubridate::ym(doterm))


postcodes_filtered <- postcodes_raw |>                       
  filter(grepl("Cardiff", ladnm) | grepl("Glamorgan", ladnm) ) #filter to cardiff and vale


#Download WIMD 2025
#https://stats.gov.wales/en-GB/9706edd9-73ad-4902-bb12-7ccd7038626e?sort_by%5BcolumnName%5D=Data%20description&sort_by%5Bdirection%5D=DESC#data

wimd2025_raw <- read_csv("input/welsh-index-of-multiple-deprivation-wimd-2025-index-and-domain-ranks-and-groups-for-lower-layer-super-output-areas-lsoa-v5.csv") |> 
  janitor::clean_names()

# wimd2025_raw |> distinct(domain)
# wimd2025_raw |> distinct(data_description)

wimd2025 <- wimd2025_raw |> 
  filter(domain == "WIMD") |>  #overall WIMD only
  filter(data_description == "Rank")

#join
postcodes_wimd <- postcodes_filtered |> 
  left_join(wimd2025, by = join_by(lsoa21cd == area_code)) |> 
  arrange(data_values, pcds) #sort by WIMD rank, then postcode alphabetical


test <- postcodes_wimd |> head()

# 
# #output
# postcodes_wimd |> 
#   write_csv(here::here('output', 'ONS_postcode_WIMD2025.csv'))
