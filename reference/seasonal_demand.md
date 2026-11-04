# Seasonal demand profile for short-stay places

Works out how busy each place is in each calendar month, using guest
reviews as a stand-in for bookings. Demand is shown as an index where 1
is that place's own average month, so a small town and the Melbourne CBD
can sit on the same chart. A value of 2 means a month is twice as busy
as usual for that place, and 0.5 means half as busy.

## Usage

``` r
seasonal_demand(
  places,
  stay_type = "Short stay (under 28 nights)",
  room_type = "Entire home/apt",
  baseline = "Melbourne CBD",
  reviews = staysvic::vic_reviews_monthly
)
```

## Arguments

- places:

  Character vector of place names from
  [vic_places](https://etc5523-2026.github.io/etc5523-assignment-4-devaansh-ops/reference/vic_places.md)
  or the `place` column of
  [vic_listings](https://etc5523-2026.github.io/etc5523-assignment-4-devaansh-ops/reference/vic_listings.md),
  for example `c("Lorne", "Sorrento")`.

- stay_type:

  Which listings to count. One of `"Short stay (under 28 nights)"` (the
  default), `"Mid stay (28 nights or more)"` or `"All"`.

- room_type:

  One of `"Entire home/apt"` (the default), `"Private room"`,
  `"Hotel room"`, `"Shared room"` or `"All"`.

- baseline:

  A place that is always included for comparison. Defaults to
  `"Melbourne CBD"`. Use `NULL` to leave it out.

- reviews:

  Monthly review counts. Defaults to
  [vic_reviews_monthly](https://etc5523-2026.github.io/etc5523-assignment-4-devaansh-ops/reference/vic_reviews_monthly.md).

## Value

A tibble with one row per place and calendar month, containing `place`,
`month` (1 to 12), `month_label`, `avg_reviews` (average reviews in that
month across years), `index` (the month compared with the place's
average month), `total_reviews` (all reviews for the place in the data)
and `enough_data` (`TRUE` when there are at least 100 reviews, which
keeps one busy weekend from looking like a trend).

## Details

Months are averaged across every year in the data, so each calendar
month appears about three times.

## Examples

``` r
seasonal_demand(c("Lorne", "Apollo Bay"))
#> # A tibble: 36 × 7
#>    place         month month_label avg_reviews index total_reviews enough_data
#>    <chr>         <int> <fct>             <dbl> <dbl>         <int> <lgl>      
#>  1 Melbourne CBD     1 Jan               6413. 1.08         214262 TRUE       
#>  2 Melbourne CBD     2 Feb               5705  0.959        214262 TRUE       
#>  3 Melbourne CBD     3 Mar               6332  1.06         214262 TRUE       
#>  4 Melbourne CBD     4 Apr               5653  0.950        214262 TRUE       
#>  5 Melbourne CBD     5 May               5363  0.901        214262 TRUE       
#>  6 Melbourne CBD     6 Jun               5465. 0.918        214262 TRUE       
#>  7 Melbourne CBD     7 Jul               6244. 1.05         214262 TRUE       
#>  8 Melbourne CBD     8 Aug               6247. 1.05         214262 TRUE       
#>  9 Melbourne CBD     9 Sep               6342  1.07         214262 TRUE       
#> 10 Melbourne CBD    10 Oct               5709. 0.959        214262 TRUE       
#> # ℹ 26 more rows

# Peak month for each place
prof <- seasonal_demand(c("Lorne", "Sorrento"))
prof[prof$index == ave(prof$index, prof$place, FUN = max), ]
#> # A tibble: 3 × 7
#>   place         month month_label avg_reviews index total_reviews enough_data
#>   <chr>         <int> <fct>             <dbl> <dbl>         <int> <lgl>      
#> 1 Melbourne CBD     1 Jan               6413.  1.08        214262 TRUE       
#> 2 Lorne             1 Jan                344   1.29          9566 TRUE       
#> 3 Sorrento          1 Jan                281.  1.5           6736 TRUE       
```
