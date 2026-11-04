# How many booked nights a short stay needs to beat a normal rental

Compares the money from renting a whole home as a short stay with the
money from a normal long-term lease. It answers one plain question: how
many nights a month would the place need to be booked before it earns
more than the rent?

## Usage

``` r
breakeven_nights(
  place,
  bedrooms,
  weekly_rent = NULL,
  costs = 0.2,
  review_rate = 0.5,
  avg_stay = 3,
  listings = staysvic::vic_listings,
  reviews = staysvic::vic_reviews_monthly,
  rents = staysvic::vic_rents
)
```

## Arguments

- place:

  A single place name.

- bedrooms:

  Number of bedrooms, 1 to 4. Four means four or more.

- weekly_rent:

  Weekly rent you could get on a normal lease, in dollars. If `NULL`
  (the default), the latest Homes Victoria median for the place's suburb
  group is used, when one exists. Homes Victoria does not publish a
  median for every area (small towns such as Lorne and Port Campbell
  have none), so supply your own figure for those places.

- costs:

  Share of each night's price lost to platform fees, cleaning, supplies
  and management. Defaults to 0.2 (20 per cent).

- review_rate:

  Share of stays that end with a review. Defaults to 0.5.

- avg_stay:

  Typical stay length in nights. Defaults to 3.

- listings, reviews, rents:

  Data to use. Default to
  [vic_listings](https://etc5523-2026.github.io/etc5523-assignment-4-devaansh-ops/reference/vic_listings.md),
  [vic_reviews_monthly](https://etc5523-2026.github.io/etc5523-assignment-4-devaansh-ops/reference/vic_reviews_monthly.md)
  and
  [vic_rents](https://etc5523-2026.github.io/etc5523-assignment-4-devaansh-ops/reference/vic_rents.md).

## Value

A one-row tibble with `place`, `bedrooms`, `n_listings`, `median_price`,
`weekly_rent`, `rent_source`, `nights_needed`, `est_nights_avg`,
`est_nights_peak`, `est_nights_low`, `peak_month`, `low_month`,
`reliable` (`FALSE` when the answer rests on too little data), `note`, a
plain-language message that explains any problem, and `monthly`, a list
column holding a tibble of estimated booked nights for each calendar
month over the last 12 months.

## Details

The calculation is

\$\$nights = \frac{weekly\\ rent \times 52 / 12}{nightly\\ price \times
(1 - costs)}\$\$

where the nightly price is the median for active, whole-home short stays
with the chosen number of bedrooms in that place.

To give the answer some context, it also estimates how many nights a
typical listing in the place is actually booked each month. This uses
the same rough rule as Inside Airbnb: about half of guests leave a
review, and a typical stay is about three nights, so each review stands
for roughly six booked nights. The estimate is capped at 21 nights a
month (70 per cent of a month) so one very busy listing cannot push it
to absurd levels. Treat it as a guide to the size of the gap, not a
forecast.

## Examples

``` r
breakeven_nights("Geelong", bedrooms = 3)
#> # A tibble: 1 × 15
#>   place   bedrooms n_listings median_price weekly_rent rent_source nights_needed
#>   <chr>      <int>      <int>        <dbl>       <dbl> <chr>               <dbl>
#> 1 Geelong        3         70         329.         480 Homes Vict…          7.90
#> # ℹ 8 more variables: est_nights_avg <dbl>, est_nights_peak <dbl>,
#> #   est_nights_low <dbl>, peak_month <chr>, low_month <chr>, reliable <lgl>,
#> #   note <chr>, monthly <list>

# Places with no published rent need your own figure
breakeven_nights("Port Campbell", bedrooms = 2, weekly_rent = 550)
#> # A tibble: 1 × 15
#>   place   bedrooms n_listings median_price weekly_rent rent_source nights_needed
#>   <chr>      <int>      <int>        <dbl>       <dbl> <chr>               <dbl>
#> 1 Port C…        2         27          400         550 Your figure          7.45
#> # ℹ 8 more variables: est_nights_avg <dbl>, est_nights_peak <dbl>,
#> #   est_nights_low <dbl>, peak_month <chr>, low_month <chr>, reliable <lgl>,
#> #   note <chr>, monthly <list>

# Use your own rent estimate and higher costs
breakeven_nights("Melbourne CBD", bedrooms = 1, weekly_rent = 550, costs = 0.3)
#> # A tibble: 1 × 15
#>   place   bedrooms n_listings median_price weekly_rent rent_source nights_needed
#>   <chr>      <int>      <int>        <dbl>       <dbl> <chr>               <dbl>
#> 1 Melbou…        1       1264         232.         550 Your figure          14.7
#> # ℹ 8 more variables: est_nights_avg <dbl>, est_nights_peak <dbl>,
#> #   est_nights_low <dbl>, peak_month <chr>, low_month <chr>, reliable <lgl>,
#> #   note <chr>, monthly <list>
```
