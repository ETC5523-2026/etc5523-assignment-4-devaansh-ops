# Monthly Airbnb reviews by place

Guest reviews counted by place and month for the three years before the
snapshot. Reviews are the best public stand-in for bookings, because a
guest can only review after they stay. Not every guest leaves one, so
the counts are lower than the real number of stays, but the pattern
through the year is still useful.

## Usage

``` r
vic_reviews_monthly
```

## Format

A tibble with these columns:

- zone, place:

  As in
  [vic_listings](https://etc5523-2026.github.io/etc5523-assignment-4-devaansh-ops/reference/vic_listings.md).

- stay_type, room_type:

  As in
  [vic_listings](https://etc5523-2026.github.io/etc5523-assignment-4-devaansh-ops/reference/vic_listings.md),
  based on the listing's settings at the time of the snapshot.

- month:

  First day of the month.

- reviews:

  Reviews left that month.

- listings_reviewed:

  Separate listings that got at least one review.

## Source

Inside Airbnb, <https://insideairbnb.com/get-the-data/>, licensed under
CC BY 4.0. Prepared by `data-raw/02_airbnb.R`.
