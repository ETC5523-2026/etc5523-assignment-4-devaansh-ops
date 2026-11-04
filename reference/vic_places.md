# Town centres used to group listings

The towns that listings are matched to. A listing belongs to a town when
it sits within `radius_km` of the town centre. Coordinates are
approximate main-street locations.

## Usage

``` r
vic_places
```

## Format

A tibble with these columns:

- place:

  Town name.

- zone:

  Broad area the town belongs to.

- lat, long:

  Approximate town centre.

- radius_km:

  How far from the centre a listing can be and still count.

## Source

Compiled for this package in `data-raw/00_places.R`.
