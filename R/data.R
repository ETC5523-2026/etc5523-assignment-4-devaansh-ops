#' Airbnb listings in Melbourne and regional Victoria
#'
#' One row per Airbnb listing in the newest Inside Airbnb snapshots for
#' Melbourne, the Mornington Peninsula and Barwon South West (which covers
#' Geelong, the Bellarine and the Great Ocean Road). Listing names,
#' descriptions and the names of small hosts are left out.
#'
#' @format A tibble with one row per listing and these columns:
#' \describe{
#'   \item{id}{Airbnb listing ID.}
#'   \item{region}{Inside Airbnb file the listing came from.}
#'   \item{snapshot}{Date Inside Airbnb collected the data.}
#'   \item{zone}{Broad area, such as "Great Ocean Road" or "Melbourne CBD".}
#'   \item{place}{Town the listing is matched to (see [vic_places]), or its
#'     council area when it is not near any listed town.}
#'   \item{lga}{Local government area (council) as given by Inside Airbnb.}
#'   \item{latitude, longitude}{Approximate location. Airbnb blurs these by
#'     up to about 150 metres.}
#'   \item{room_type}{"Entire home/apt", "Private room", "Hotel room" or
#'     "Shared room".}
#'   \item{property_type}{Host's own description, such as "Entire cottage".}
#'   \item{is_hotel}{`TRUE` for hotel rooms and serviced apartments listed on Airbnb.}
#'   \item{stay_type}{"Short stay (under 28 nights)" or "Mid stay (28 nights
#'     or more)", based on the minimum stay. The 28-night line follows
#'     Victoria's short stay levy.}
#'   \item{minimum_nights}{Shortest stay the host accepts.}
#'   \item{bedrooms}{Number of bedrooms, with 4 meaning four or more.}
#'   \item{price}{Nightly price in Australian dollars on the day of the
#'     snapshot. Missing when the host had no dates open.}
#'   \item{host_id}{Airbnb host ID.}
#'   \item{host_listings}{Listings this host runs across all three regions.}
#'   \item{host_tier}{"Single listing", "2 to 9 listings" or "10 or more listings".}
#'   \item{operator}{Host name, kept only for hosts with 10 or more listings.}
#'   \item{availability_365}{Nights open for booking in the next year.}
#'   \item{number_of_reviews_ltm}{Reviews in the last 12 months.}
#'   \item{active}{`TRUE` if the listing had a review in the last 12 months.}
#' }
#' @source Inside Airbnb, <https://insideairbnb.com/get-the-data/>, licensed
#'   under CC BY 4.0. Prepared by `data-raw/02_airbnb.R`.
"vic_listings"

#' Monthly Airbnb reviews by place
#'
#' Guest reviews counted by place and month for the three years before the
#' snapshot. Reviews are the best public stand-in for bookings, because a
#' guest can only review after they stay. Not every guest leaves one, so the
#' counts are lower than the real number of stays, but the pattern through
#' the year is still useful.
#'
#' @format A tibble with these columns:
#' \describe{
#'   \item{zone, place}{As in [vic_listings].}
#'   \item{stay_type, room_type}{As in [vic_listings], based on the
#'     listing's settings at the time of the snapshot.}
#'   \item{month}{First day of the month.}
#'   \item{reviews}{Reviews left that month.}
#'   \item{listings_reviewed}{Separate listings that got at least one review.}
#' }
#' @source Inside Airbnb, <https://insideairbnb.com/get-the-data/>, licensed
#'   under CC BY 4.0. Prepared by `data-raw/02_airbnb.R`.
"vic_reviews_monthly"

#' Median weekly rents by council area
#'
#' The latest moving annual median weekly rent for new leases, by local
#' government area and dwelling type, from the Homes Victoria Rental Report.
#' "Moving annual" means each figure covers the twelve months up to the
#' quarter shown, which smooths out seasonal swings.
#'
#' @format A tibble with these columns:
#' \describe{
#'   \item{lga}{Local government area.}
#'   \item{bedrooms}{Number of bedrooms.}
#'   \item{dwelling_type}{"Flat" or "House".}
#'   \item{median_weekly_rent}{Median weekly rent in dollars.}
#'   \item{quarter}{Quarter the twelve-month period ends in.}
#'   \item{source}{Name of the file the figure came from.}
#' }
#' @source Homes Victoria, Rental Report: moving annual rents,
#'   <https://discover.data.vic.gov.au/dataset/rental-report-quarterly-moving-annual-rents-by-suburb>,
#'   licensed under CC BY 4.0. Prepared by `data-raw/03_rents.R`.
"vic_rents"

#' Town centres used to group listings
#'
#' The towns that listings are matched to. A listing belongs to a town when
#' it sits within `radius_km` of the town centre. Coordinates are approximate
#' main-street locations.
#'
#' @format A tibble with these columns:
#' \describe{
#'   \item{place}{Town name.}
#'   \item{zone}{Broad area the town belongs to.}
#'   \item{lat, long}{Approximate town centre.}
#'   \item{radius_km}{How far from the centre a listing can be and still count.}
#' }
#' @source Compiled for this package in `data-raw/00_places.R`.
"vic_places"
