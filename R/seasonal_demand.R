#' Seasonal demand profile for short-stay places
#'
#' Works out how busy each place is in each calendar month, using guest
#' reviews as a stand-in for bookings. Demand is shown as an index where 1
#' is that place's own average month, so a small town and the Melbourne CBD
#' can sit on the same chart. A value of 2 means a month is twice as busy as
#' usual for that place, and 0.5 means half as busy.
#'
#' Months are averaged across every year in the data, so each calendar month
#' appears about three times.
#'
#' @param places Character vector of place names from [vic_places] or the
#'   `place` column of [vic_listings], for example `c("Lorne", "Sorrento")`.
#' @param stay_type Which listings to count. One of
#'   `"Short stay (under 28 nights)"` (the default),
#'   `"Mid stay (28 nights or more)"` or `"All"`.
#' @param room_type One of `"Entire home/apt"` (the default),
#'   `"Private room"`, `"Hotel room"`, `"Shared room"` or `"All"`.
#' @param baseline A place that is always included for comparison. Defaults
#'   to `"Melbourne CBD"`. Use `NULL` to leave it out.
#' @param reviews Monthly review counts. Defaults to [vic_reviews_monthly].
#'
#' @return A tibble with one row per place and calendar month, containing
#'   `place`, `month` (1 to 12), `month_label`, `avg_reviews` (average
#'   reviews in that month across years), `index` (the month compared with
#'   the place's average month), `total_reviews` (all reviews for the place
#'   in the data) and `enough_data` (`TRUE` when there are at least 100
#'   reviews, which keeps one busy weekend from looking like a trend).
#'
#' @examples
#' seasonal_demand(c("Lorne", "Apollo Bay"))
#'
#' # Peak month for each place
#' prof <- seasonal_demand(c("Lorne", "Sorrento"))
#' prof[prof$index == ave(prof$index, prof$place, FUN = max), ]
#' @export
seasonal_demand <- function(places,
                            stay_type = "Short stay (under 28 nights)",
                            room_type = "Entire home/apt",
                            baseline = "Melbourne CBD",
                            reviews = staysvic::vic_reviews_monthly) {
  check_choice(stay_type, c(unique(reviews$stay_type), "All"), "stay_type")
  check_choice(room_type, c(unique(reviews$room_type), "All"), "room_type")

  keep <- unique(c(baseline, places))
  x <- reviews[reviews$place %in% keep, , drop = FALSE]
  if (stay_type != "All") x <- x[x$stay_type == stay_type, , drop = FALSE]
  if (room_type != "All") x <- x[x$room_type == room_type, , drop = FALSE]

  empty <- tibble::tibble(place = character(), month = integer(),
                          month_label = factor(levels = month.abb),
                          avg_reviews = numeric(), index = numeric(),
                          total_reviews = integer(), enough_data = logical())
  if (nrow(x) == 0) return(empty)

  x |>
    dplyr::mutate(year = as.integer(format(.data$month, "%Y")),
                  month = as.integer(format(.data$month, "%m"))) |>
    dplyr::group_by(.data$place, .data$year, .data$month) |>
    dplyr::summarise(reviews = sum(.data$reviews), .groups = "drop") |>
    dplyr::group_by(.data$place, .data$month) |>
    dplyr::summarise(avg_reviews = mean(.data$reviews),
                     sum_reviews = sum(.data$reviews), .groups = "drop") |>
    dplyr::group_by(.data$place) |>
    dplyr::mutate(
      total_reviews = as.integer(sum(.data$sum_reviews)),
      index = if (mean(.data$avg_reviews) > 0) {
        .data$avg_reviews / mean(.data$avg_reviews)
      } else {
        NA_real_
      },
      enough_data = .data$total_reviews >= 100
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(month_label = factor(month.abb[.data$month], levels = month.abb),
                  place = factor(.data$place, levels = keep)) |>
    dplyr::arrange(.data$place, .data$month) |>
    dplyr::mutate(place = as.character(.data$place)) |>
    dplyr::select("place", "month", "month_label", "avg_reviews", "index",
                  "total_reviews", "enough_data")
}

check_choice <- function(x, choices, arg) {
  if (length(x) != 1 || !x %in% choices) {
    stop("`", arg, "` must be one of: ", paste0("\"", choices, "\"", collapse = ", "),
         call. = FALSE)
  }
  invisible(x)
}
