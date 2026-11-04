# Airbnb listings in Melbourne and regional Victoria

One row per Airbnb listing in the newest Inside Airbnb snapshots for
Melbourne, the Mornington Peninsula and Barwon South West (which covers
Geelong, the Bellarine and the Great Ocean Road). Listing names,
descriptions and the names of small hosts are left out.

## Usage

``` r
vic_listings
```

## Format

A tibble with one row per listing and these columns:

- id:

  Airbnb listing ID.

- region:

  Inside Airbnb file the listing came from.

- snapshot:

  Date Inside Airbnb collected the data.

- zone:

  Broad area, such as "Great Ocean Road" or "Melbourne CBD".

- place:

  Town the listing is matched to (see
  [vic_places](https://etc5523-2026.github.io/etc5523-assignment-4-devaansh-ops/reference/vic_places.md)),
  or its council area when it is not near any listed town.

- lga:

  Local government area (council) as given by Inside Airbnb.

- latitude, longitude:

  Approximate location. Airbnb blurs these by up to about 150 metres.

- room_type:

  "Entire home/apt", "Private room", "Hotel room" or "Shared room".

- property_type:

  Host's own description, such as "Entire cottage".

- is_hotel:

  `TRUE` for hotel rooms and serviced apartments listed on Airbnb.

- stay_type:

  "Short stay (under 28 nights)" or "Mid stay (28 nights or more)",
  based on the minimum stay. The 28-night line follows Victoria's short
  stay levy.

- minimum_nights:

  Shortest stay the host accepts.

- bedrooms:

  Number of bedrooms, with 4 meaning four or more.

- price:

  Nightly price in Australian dollars on the day of the snapshot.
  Missing when the host had no dates open.

- host_id:

  Airbnb host ID.

- host_listings:

  Listings this host runs across all three regions.

- host_tier:

  "Single listing", "2 to 9 listings" or "10 or more listings".

- operator:

  Host name, kept only for hosts with 10 or more listings.

- availability_365:

  Nights open for booking in the next year.

- number_of_reviews_ltm:

  Reviews in the last 12 months.

- active:

  `TRUE` if the listing had a review in the last 12 months.

## Source

Inside Airbnb, <https://insideairbnb.com/get-the-data/>, licensed under
CC BY 4.0. Prepared by `data-raw/02_airbnb.R`.
