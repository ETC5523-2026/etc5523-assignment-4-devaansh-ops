# Median weekly rents by council area

The latest moving annual median weekly rent for new leases, by local
government area and dwelling type, from the Homes Victoria Rental
Report. "Moving annual" means each figure covers the twelve months up to
the quarter shown, which smooths out seasonal swings.

## Usage

``` r
vic_rents
```

## Format

A tibble with these columns:

- lga:

  Local government area.

- bedrooms:

  Number of bedrooms.

- dwelling_type:

  "Flat" or "House".

- median_weekly_rent:

  Median weekly rent in dollars.

- quarter:

  Quarter the twelve-month period ends in.

- source:

  Name of the file the figure came from.

## Source

Homes Victoria, Rental Report: moving annual rents,
<https://discover.data.vic.gov.au/dataset/rental-report-quarterly-moving-annual-rents-by-suburb>,
licensed under CC BY 4.0. Prepared by `data-raw/03_rents.R`.
