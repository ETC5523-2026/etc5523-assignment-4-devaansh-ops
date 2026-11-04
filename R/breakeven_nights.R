#' How many booked nights a short stay needs to beat a normal rental
#'
#' Compares the money from renting a whole home as a short stay with the
#' money from a normal long-term lease. It answers one plain question: how
#' many nights a month would the place need to be booked before it earns
#' more than the rent?
#'
#' The calculation is
#'
#' \deqn{nights = \frac{weekly\ rent \times 52 / 12}{nightly\ price \times (1 - costs)}}{nights = (weekly rent x 52 / 12) / (nightly price x (1 - costs))}
#'
#' where the nightly price is the median for active, whole-home short stays
#' with the chosen number of bedrooms in that place.
#'
#' To give the answer some context, it also estimates how many nights a
#' typical listing in the place is actually booked each month. This uses the
#' same rough rule as Inside Airbnb: about half of guests leave a review, and
#' a typical stay is about three nights, so each review stands for roughly
#' six booked nights. The estimate is capped at 21 nights a month (70 per
#' cent of a month) so one very busy listing cannot push it to absurd
#' levels. Treat it as a guide to the size of the gap, not a forecast.
#'
#' @param place A single place name.
#' @param bedrooms Number of bedrooms, 1 to 4. Four means four or more.
#' @param weekly_rent Weekly rent you could get on a normal lease, in
#'   dollars. If `NULL` (the default), the latest Homes Victoria median for
#'   the place's suburb group is used, when one exists. Homes Victoria does
#'   not publish a median for every area (small towns such as Lorne and Port
#'   Campbell have none), so supply your own figure for those places.
#' @param costs Share of each night's price lost to platform fees, cleaning,
#'   supplies and management. Defaults to 0.2 (20 per cent).
#' @param review_rate Share of stays that end with a review. Defaults to 0.5.
#' @param avg_stay Typical stay length in nights. Defaults to 3.
#' @param listings,reviews,rents Data to use. Default to [vic_listings],
#'   [vic_reviews_monthly] and [vic_rents].
#'
#' @return A one-row tibble with `place`, `bedrooms`, `n_listings`,
#'   `median_price`, `weekly_rent`, `rent_source`, `nights_needed`,
#'   `est_nights_avg`, `est_nights_peak`, `est_nights_low`, `peak_month`,
#'   `low_month`, `reliable` (`FALSE` when the answer rests on too little
#'   data), `note`, a plain-language message that explains any problem, and
#'   `monthly`, a list column holding a tibble of estimated booked nights for
#'   each calendar month over the last 12 months.
#'
#' @examples
#' breakeven_nights("Geelong", bedrooms = 3)
#'
#' # Places with no published rent need your own figure
#' breakeven_nights("Port Campbell", bedrooms = 2, weekly_rent = 550)
#'
#' # Use your own rent estimate and higher costs
#' breakeven_nights("Melbourne CBD", bedrooms = 1, weekly_rent = 550, costs = 0.3)
#' @export
breakeven_nights <- function(place, bedrooms, weekly_rent = NULL, costs = 0.2,
                             review_rate = 0.5, avg_stay = 3,
                             listings = staysvic::vic_listings,
                             reviews = staysvic::vic_reviews_monthly,
                             rents = staysvic::vic_rents) {
  if (length(place) != 1) stop("`place` must be a single place name.", call. = FALSE)
  if (!bedrooms %in% 1:4) stop("`bedrooms` must be 1, 2, 3 or 4.", call. = FALSE)
  if (costs < 0 || costs >= 1) stop("`costs` must be between 0 and 1.", call. = FALSE)

  short <- "Short stay (under 28 nights)"
  homes <- listings[listings$place == place & listings$active &
                      listings$stay_type == short &
                      listings$room_type == "Entire home/apt", , drop = FALSE]
  same_size <- homes[!is.na(homes$bedrooms) & homes$bedrooms == bedrooms &
                       !is.na(homes$price), , drop = FALSE]
  n <- nrow(same_size)
  median_price <- if (n > 0) stats::median(same_size$price) else NA_real_

  # Long-term rent: user's own figure, or the Homes Victoria median
  rent_source <- "Your figure"
  if (is.null(weekly_rent) || is.na(weekly_rent)) {
    weekly_rent <- NA_real_
    rent_source <- "Not available"
    if (nrow(homes) > 0 && nrow(rents) > 0) {
      lga <- names(sort(table(homes$lga), decreasing = TRUE))[1]
      pool <- rents[rents$bedrooms == bedrooms, , drop = FALSE]
      # The rent file is by suburb group (for example "Torquay-Jan Juc"), so
      # match on the town name first, then the council name
      match <- pool[rent_area_matches(pool$lga, sub("^Rest of ", "", place)), , drop = FALSE]
      if (nrow(match) == 0) {
        match <- pool[rent_area_matches(pool$lga, lga), , drop = FALSE]
      }
      if (nrow(match) > 0) {
        # A flat for 1 or 2 bedrooms, a house for 3 or more
        preferred <- if (bedrooms <= 2) "Flat" else "House"
        pick <- match[match$dwelling_type == preferred, , drop = FALSE]
        if (nrow(pick) == 0) pick <- match
        weekly_rent <- pick$median_weekly_rent[1]
        rent_source <- paste0("Homes Victoria median, ", pick$lga[1], ", ",
                              bedrooms, " bedroom ", tolower(pick$dwelling_type[1]),
                              ", ", pick$quarter[1])
      }
    }
  }

  monthly_rent <- weekly_rent * 52 / 12
  nights_needed <- monthly_rent / (median_price * (1 - costs))

  # Estimated booked nights per listing per month, over the last 12 months
  r <- reviews[reviews$place == place & reviews$stay_type == short &
                 reviews$room_type == "Entire home/apt", , drop = FALSE]
  est <- c(avg = NA_real_, peak = NA_real_, low = NA_real_)
  peak_month <- low_month <- NA_character_
  monthly <- tibble::tibble(month = integer(), month_label = factor(levels = month.abb),
                            est_nights = numeric())
  if (nrow(r) > 0 && nrow(homes) > 0) {
    r <- r[r$month > max(r$month) - 365, , drop = FALSE]
    per_month <- tapply(r$reviews, as.integer(format(r$month, "%m")), sum) / nrow(homes)
    nights <- pmin(per_month / review_rate * avg_stay, 21)
    est <- c(avg = mean(nights), peak = max(nights), low = min(nights))
    peak_month <- month.name[as.integer(names(nights)[which.max(nights)])]
    low_month  <- month.name[as.integer(names(nights)[which.min(nights)])]
    m <- as.integer(names(nights))
    monthly <- tibble::tibble(month = m,
                              month_label = factor(month.abb[m], levels = month.abb),
                              est_nights = as.numeric(nights))
  }

  note <- if (n == 0) {
    paste0("There are no active ", bedrooms, " bedroom whole-home short stays in ",
           place, ". Try a different number of bedrooms or a nearby place.")
  } else if (n < 10) {
    paste0("Only ", n, " active ", bedrooms, " bedroom whole homes in ", place,
           ". A median from so few listings can swing a lot, so treat this as a rough guide.")
  } else if (is.na(weekly_rent)) {
    paste0("There is no Homes Victoria rent figure for this area and size. ",
           "Type in a weekly rent you think you could get.")
  } else {
    "Enough listings for a fair comparison."
  }

  tibble::tibble(
    place = place, bedrooms = as.integer(bedrooms), n_listings = n,
    median_price = median_price, weekly_rent = weekly_rent,
    rent_source = rent_source, nights_needed = nights_needed,
    est_nights_avg = unname(est["avg"]), est_nights_peak = unname(est["peak"]),
    est_nights_low = unname(est["low"]),
    peak_month = peak_month, low_month = low_month,
    reliable = n >= 10 && !is.na(weekly_rent),
    note = note,
    monthly = list(monthly)
  )
}

lga_key <- function(x) {
  x <- tolower(x)
  x <- gsub("\\b(city of|shire of|borough of|rural city of|shire|city|council|borough)\\b", "", x)
  gsub("[^a-z]", "", x)
}

# TRUE where any dash-separated part of a rent area name equals `name`
rent_area_matches <- function(areas, name) {
  if (grepl("cbd", name, ignore.case = TRUE)) name <- "CBD"
  target <- lga_key(name)
  if (!nzchar(target)) return(rep(FALSE, length(areas)))
  vapply(strsplit(areas, "\\s*-\\s*"), function(parts) {
    any(lga_key(parts) == target)
  }, logical(1))
}
