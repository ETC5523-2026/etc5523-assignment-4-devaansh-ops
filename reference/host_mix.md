# Who runs the short stays in a place

Splits a place's listings by how many listings their host runs across
Victoria. A host with one listing is usually someone renting out their
own place or holiday home. A host with ten or more is almost always a
management company. The result also reports how many listings in the
place are hotel rooms or serviced apartments advertised on Airbnb.

## Usage

``` r
host_mix(
  places,
  baseline = "Melbourne CBD",
  active_only = TRUE,
  listings = staysvic::vic_listings
)
```

## Arguments

- places:

  Character vector of place names.

- baseline:

  A place that is always included for comparison. Defaults to
  `"Melbourne CBD"`. Use `NULL` to leave it out.

- active_only:

  If `TRUE` (the default), only count listings with at least one review
  in the last 12 months, which filters out listings that are left up but
  rarely booked.

- listings:

  Listing data. Defaults to
  [vic_listings](https://etc5523-2026.github.io/etc5523-assignment-4-devaansh-ops/reference/vic_listings.md).

## Value

A tibble with one row per place and host tier, containing `place`,
`host_tier`, `listings`, `share` (proportion of the place's listings),
`total` (all listings in the place), `hotel_share` (proportion that are
hotel rooms or serviced apartments) and `entire_share` (proportion that
are entire homes).

## See also

[`top_operators()`](https://etc5523-2026.github.io/etc5523-assignment-4-devaansh-ops/reference/top_operators.md)
for the biggest operators in one place.

## Examples

``` r
host_mix(c("Lorne", "Torquay"))
#> # A tibble: 9 × 7
#>   place         host_tier          listings share total hotel_share entire_share
#>   <chr>         <fct>                 <int> <dbl> <int>       <dbl>        <dbl>
#> 1 Melbourne CBD Single listing          862 0.182  4739     0.0336         0.928
#> 2 Melbourne CBD 2 to 9 listings        1494 0.315  4739     0.0336         0.928
#> 3 Melbourne CBD 10 or more listin…     2383 0.503  4739     0.0336         0.928
#> 4 Lorne         Single listing           93 0.318   292     0.0274         0.962
#> 5 Lorne         2 to 9 listings          55 0.188   292     0.0274         0.962
#> 6 Lorne         10 or more listin…      144 0.493   292     0.0274         0.962
#> 7 Torquay       Single listing          265 0.447   593     0.00337        0.929
#> 8 Torquay       2 to 9 listings          91 0.153   593     0.00337        0.929
#> 9 Torquay       10 or more listin…      237 0.400   593     0.00337        0.929
```
