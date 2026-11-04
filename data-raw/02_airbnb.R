# 02_airbnb.R
# Cleans the Inside Airbnb files into two package datasets:
#   vic_listings         one row per listing (the newest snapshot)
#   vic_reviews_monthly  reviews counted by place, month, stay type and room type
#
# Run 01_download.R and 00_places.R first.

library(dplyr)
library(readr)
library(tidyr)

raw_dir    <- "data-raw/raw"
snapshots  <- read_csv(file.path(raw_dir, "airbnb_snapshots.csv"), show_col_types = FALSE)
lga_zones  <- readRDS("data-raw/lga_zones.rds")
load("data/vic_places.rda")

key <- function(x) {
  x <- tolower(x)
  x <- gsub("\\b(city of|shire of|borough of|rural city of)\\b", "", x)
  x <- gsub("\\b(shire|city|council|borough)\\b", "", x)
  gsub("[^a-z]", "", x)
}

parse_price <- function(x) suppressWarnings(as.numeric(gsub("[$,]", "", x)))

# Great-circle distance in km between one point and many points
dist_km <- function(lat1, lon1, lat2, lon2) {
  rad <- pi / 180
  a <- sin((lat2 - lat1) * rad / 2)^2 +
    cos(lat1 * rad) * cos(lat2 * rad) * sin((lon2 - lon1) * rad / 2)^2
  6371 * 2 * asin(pmin(1, sqrt(a)))
}

# ---- Listings -------------------------------------------------------------

keep_cols <- c("id", "host_id", "host_name", "neighbourhood_cleansed",
               "latitude", "longitude", "property_type", "room_type",
               "bedrooms", "price", "minimum_nights", "availability_365",
               "number_of_reviews", "number_of_reviews_ltm")

read_listings <- function(region, date) {
  path <- file.path(raw_dir, sprintf("%s_%s_listings.csv.gz", region, date))
  x <- read_csv(path, col_types = cols(.default = col_character()),
                show_col_types = FALSE)
  missing <- setdiff(keep_cols, names(x))
  if (length(missing) > 0) stop("Missing columns in ", path, ": ",
                                paste(missing, collapse = ", "))
  x |>
    select(all_of(keep_cols)) |>
    mutate(region = region, snapshot = as.Date(date))
}

raw <- purrr::map2_dfr(snapshots$region, snapshots$date, read_listings)

listings <- raw |>
  mutate(
    across(c(latitude, longitude), as.numeric),
    across(c(bedrooms, minimum_nights, availability_365,
             number_of_reviews, number_of_reviews_ltm), as.integer),
    price = parse_price(price)
  ) |>
  # A listing near a region border can appear in two files. Keep one copy,
  # from the newest snapshot.
  arrange(desc(snapshot)) |>
  distinct(id, .keep_all = TRUE)

# Match each listing to its nearest town, if it is close enough
nearest <- vapply(seq_len(nrow(listings)), function(i) {
  d <- dist_km(listings$latitude[i], listings$longitude[i],
               vic_places$lat, vic_places$long)
  inside <- which(d <= vic_places$radius_km)
  if (length(inside) == 0) NA_integer_ else inside[which.min(d[inside])]
}, integer(1))

lga_with_towns <- unique(c(
  listings$neighbourhood_cleansed[!is.na(nearest)],
  if (any(listings$region == "mornington-peninsula")) "Mornington Peninsula"
))

# The Mornington Peninsula file splits the shire into wards ("Point Nepean",
# "Rosebud - McCrae" and so on) instead of naming the council, so every
# listing in that file is given the shire as its LGA.
region_zones <- c("melbourne" = "Greater Melbourne",
                  "mornington-peninsula" = "Mornington Peninsula",
                  "barwon-south-west-vic" = "Western Victoria")

vic_listings <- listings |>
  mutate(
    lga      = ifelse(region == "mornington-peninsula", "Mornington Peninsula",
                      neighbourhood_cleansed),
    lga_key  = key(lga),
    town     = vic_places$place[nearest],
    town_zone = vic_places$zone[nearest]
  ) |>
  left_join(lga_zones, by = "lga_key") |>
  mutate(
    lga_label = ifelse(lga_key == "melbourne", "City of Melbourne", lga),
    place = case_when(
      !is.na(town)                 ~ town,
      lga %in% lga_with_towns      ~ paste("Rest of", lga_label),
      TRUE                         ~ lga_label
    ),
    zone = coalesce(town_zone, zone, unname(region_zones[region]), "Other Victoria"),
    # Victoria's short stay levy treats a stay under 28 consecutive nights
    # as a short stay, so the same line is used here.
    stay_type = ifelse(minimum_nights < 28, "Short stay (under 28 nights)",
                       "Mid stay (28 nights or more)"),
    is_hotel = room_type == "Hotel room" |
      grepl("hotel|serviced apartment|aparthotel", property_type,
            ignore.case = TRUE),
    bedrooms = pmin(bedrooms, 4L),
    # A listing counts as active if a guest reviewed it in the last year
    active = number_of_reviews_ltm > 0
  ) |>
  group_by(host_id) |>
  mutate(host_listings = n()) |>
  ungroup() |>
  mutate(
    host_tier = cut(host_listings, c(0, 1, 9, Inf),
                    labels = c("Single listing", "2 to 9 listings",
                               "10 or more listings")),
    # Names are kept only for operators running 10 or more listings, which
    # are businesses. Names of smaller hosts are dropped for privacy.
    operator = ifelse(host_listings >= 10, host_name, NA_character_)
  ) |>
  select(id, region, snapshot, zone, place, lga, latitude, longitude,
         room_type, property_type, is_hotel, stay_type, minimum_nights,
         bedrooms, price, host_id, host_listings, host_tier, operator,
         availability_365, number_of_reviews_ltm, active)

# ---- Reviews --------------------------------------------------------------

read_reviews <- function(region, date) {
  path <- file.path(raw_dir, sprintf("%s_%s_reviews.csv", region, date))
  read_csv(path, col_types = cols(listing_id = col_character(),
                                  date = col_date()),
           show_col_types = FALSE) |>
    mutate(region = region)
}

reviews <- purrr::map2_dfr(snapshots$region, snapshots$date, read_reviews)

# Use whole months only, ending with the last full month before the earliest
# snapshot, and going back three years so each calendar month appears
# about three times.
last_month  <- lubridate::floor_date(min(snapshots$date), "month") - 1
last_month  <- lubridate::floor_date(last_month, "month")
first_month <- seq(last_month, by = "-35 months", length.out = 2)[2]

vic_reviews_monthly <- reviews |>
  # Only count a review from the file its listing was kept from
  inner_join(select(vic_listings, id, region, zone, place, stay_type, room_type),
             by = c("listing_id" = "id", "region")) |>
  mutate(month = lubridate::floor_date(date, "month")) |>
  filter(month >= first_month, month <= last_month) |>
  group_by(zone, place, stay_type, room_type, month) |>
  summarise(reviews = n(), listings_reviewed = n_distinct(listing_id),
            .groups = "drop") |>
  complete(nesting(zone, place, stay_type, room_type),
           month = seq(first_month, last_month, by = "month"),
           fill = list(reviews = 0L, listings_reviewed = 0L)) |>
  arrange(zone, place, stay_type, room_type, month)

message(nrow(vic_listings), " listings, ",
        sum(vic_reviews_monthly$reviews), " reviews kept")

usethis::use_data(vic_listings, overwrite = TRUE, compress = "xz")
usethis::use_data(vic_reviews_monthly, overwrite = TRUE, compress = "xz")
