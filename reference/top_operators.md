# Biggest short-stay operators in a place

Lists the hosts with the most listings in one place. Only hosts running
ten or more listings across Victoria are named, because these are
businesses. Smaller hosts are grouped together so that no private person
is identified.

## Usage

``` r
top_operators(
  place,
  n = 5,
  active_only = TRUE,
  listings = staysvic::vic_listings
)
```

## Arguments

- place:

  A single place name.

- n:

  How many operators to return. Defaults to 5.

- active_only:

  If `TRUE` (the default), only count listings with at least one review
  in the last 12 months, which filters out listings that are left up but
  rarely booked.

- listings:

  Listing data. Defaults to
  [vic_listings](https://etc5523-2026.github.io/etc5523-assignment-4-devaansh-ops/reference/vic_listings.md).

## Value

A tibble with `operator`, `listings` (in this place), `share` (of all
listings in this place) and `listings_vic` (across Victoria).

## Examples

``` r
top_operators("Melbourne CBD")
#> # A tibble: 5 × 4
#>   operator           listings  share listings_vic
#>   <chr>                 <int>  <dbl>        <int>
#> 1 Advante Homes            82 0.0173           92
#> 2 Adji                     67 0.0141           84
#> 3 Rodelia                  60 0.0127          106
#> 4 Bedspoke Melbourne       59 0.0124          108
#> 5 Eduardo                  58 0.0122          112
```
