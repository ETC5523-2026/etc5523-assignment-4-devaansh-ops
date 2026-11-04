#' Who runs the short stays in a place
#'
#' Splits a place's listings by how many listings their host runs across
#' Victoria. A host with one listing is usually someone renting out their own
#' place or holiday home. A host with ten or more is almost always a
#' management company. The result also reports how many listings in the
#' place are hotel rooms or serviced apartments advertised on Airbnb.
#'
#' @param places Character vector of place names.
#' @param baseline A place that is always included for comparison. Defaults
#'   to `"Melbourne CBD"`. Use `NULL` to leave it out.
#' @param active_only If `TRUE` (the default), only count listings with at
#'   least one review in the last 12 months, which filters out listings that
#'   are left up but rarely booked.
#' @param listings Listing data. Defaults to [vic_listings].
#'
#' @return A tibble with one row per place and host tier, containing
#'   `place`, `host_tier`, `listings`, `share` (proportion of the place's
#'   listings), `total` (all listings in the place), `hotel_share`
#'   (proportion that are hotel rooms or serviced apartments) and
#'   `entire_share` (proportion that are entire homes).
#'
#' @seealso [top_operators()] for the biggest operators in one place.
#' @examples
#' host_mix(c("Lorne", "Torquay"))
#' @export
host_mix <- function(places, baseline = "Melbourne CBD", active_only = TRUE,
                     listings = staysvic::vic_listings) {
  keep <- unique(c(baseline, places))
  x <- listings[listings$place %in% keep, , drop = FALSE]
  if (active_only) x <- x[x$active, , drop = FALSE]

  x |>
    dplyr::group_by(.data$place) |>
    dplyr::mutate(total = dplyr::n(),
                  hotel_share = mean(.data$is_hotel),
                  entire_share = mean(.data$room_type == "Entire home/apt")) |>
    dplyr::group_by(.data$place, .data$host_tier, .data$total,
                    .data$hotel_share, .data$entire_share) |>
    dplyr::summarise(listings = dplyr::n(), .groups = "drop") |>
    tidyr::complete(tidyr::nesting(place, total, hotel_share, entire_share),
                    host_tier, fill = list(listings = 0L)) |>
    dplyr::mutate(share = .data$listings / .data$total,
                  place = factor(.data$place, levels = keep)) |>
    dplyr::arrange(.data$place, .data$host_tier) |>
    dplyr::mutate(place = as.character(.data$place)) |>
    dplyr::select("place", "host_tier", "listings", "share", "total",
                  "hotel_share", "entire_share")
}

#' Biggest short-stay operators in a place
#'
#' Lists the hosts with the most listings in one place. Only hosts running
#' ten or more listings across Victoria are named, because these are
#' businesses. Smaller hosts are grouped together so that no private person
#' is identified.
#'
#' @param place A single place name.
#' @param n How many operators to return. Defaults to 5.
#' @inheritParams host_mix
#'
#' @return A tibble with `operator`, `listings` (in this place), `share` (of
#'   all listings in this place) and `listings_vic` (across Victoria).
#' @examples
#' top_operators("Melbourne CBD")
#' @export
top_operators <- function(place, n = 5, active_only = TRUE,
                          listings = staysvic::vic_listings) {
  x <- listings[listings$place == place, , drop = FALSE]
  if (active_only) x <- x[x$active, , drop = FALSE]
  total <- nrow(x)
  x <- x[!is.na(x$operator), , drop = FALSE]

  x |>
    dplyr::group_by(.data$host_id, .data$operator) |>
    dplyr::summarise(listings = dplyr::n(),
                     listings_vic = dplyr::first(.data$host_listings),
                     .groups = "drop") |>
    dplyr::mutate(share = .data$listings / total) |>
    dplyr::arrange(dplyr::desc(.data$listings)) |>
    utils::head(n) |>
    dplyr::select("operator", "listings", "share", "listings_vic")
}
