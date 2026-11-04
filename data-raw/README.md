# How the data is made

Run these four scripts in order from the package root (the folder with `DESCRIPTION` in it). The whole thing takes a few minutes, most of it downloading.

``` r
source("data-raw/01_download.R")  # raw files into data-raw/raw/
source("data-raw/00_places.R")    # town lookup, writes data/vic_places.rda
source("data-raw/02_airbnb.R")    # writes data/vic_listings.rda and data/vic_reviews_monthly.rda
source("data-raw/03_rents.R")     # writes data/vic_rents.rda
```

The scripts need these packages: dplyr, tidyr, readr, readxl, purrr, lubridate, jsonlite and usethis.

`data-raw/raw/` is ignored by git because the raw files are large. Anyone can rebuild it by running `01_download.R` again. The scripts always pick the newest snapshot, so numbers will shift a little each quarter.

| Script | Input | Output |
|----|----|----|
| `01_download.R` | Inside Airbnb download page, data.vic.gov.au | Raw listings, reviews and rents |
| `00_places.R` | Hand-made table of town centres | `vic_places` |
| `02_airbnb.R` | Raw listings and reviews | `vic_listings`, `vic_reviews_monthly` |
| `03_rents.R` | Raw rents spreadsheet | `vic_rents` |

## If the rent download fails

The rent file is found through the data.vic.gov.au catalogue, which can be slow or change its layout. If `01_download.R` or `03_rents.R` stops at the rent step, download the file by hand:

1.  Open the [Homes Victoria Rental Report dataset](https://discover.data.vic.gov.au/dataset/rental-report-quarterly-moving-annual-rents-by-suburb).
2.  Download the newest "Moving annual rent by suburb" or LGA Excel file.
3.  Save it as `data-raw/raw/rents_lga.xlsx`.
4.  Save a text file called `data-raw/raw/rents_source.txt` whose first line is the name of the file you downloaded.
5.  Run `source("data-raw/03_rents.R")` again.

The Homes Victoria file is organised by suburb group (for example "Torquay-Jan Juc"), and small towns are left out when too few homes are rented. That is why some places in the app have no rent figure.

Both sources use the Creative Commons Attribution 4.0 licence.
