# staysvic: City or coast?

<!-- badges: start -->

[![pkgdown](https://github.com/etc5523-2026/etc5523-assignment-4-devaansh-ops/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/etc5523-2026/etc5523-assignment-4-devaansh-ops/actions/workflows/pkgdown.yaml)

<!-- badges: end -->

**Website:** <https://etc5523-2026.github.io/etc5523-assignment-4-devaansh-ops/>

staysvic helps someone thinking about running a short-stay rental in Victoria answer one question:

> Should I run a short stay in the Melbourne CBD or on the coast, and when does it actually pay off?

It compares the CBD with towns on the Great Ocean Road (Torquay, Anglesea, Lorne, Apollo Bay, Port Campbell, Warrnambool, Port Fairy and more), the Mornington Peninsula, Geelong and the Bellarine, and the Yarra Valley.

## What is in the package

**A Shiny app** with three tabs:

- *When is it busy?* Demand through the year for each town, with the CBD as a baseline.
- *Who runs it?* How much of each market belongs to single hosts and how much to management companies.
- *Does it pay?* How many booked nights a month a short stay needs to earn more than a normal lease.

**Functions** that the app and the vignette both use:

| Function | What it does |
|------------------------------------|------------------------------------|
| `seasonal_demand()` | Monthly demand profile for chosen places, compared with each place's average month |
| `host_mix()` | Share of listings run by single hosts, small hosts and big operators |
| `top_operators()` | The largest operators in one place |
| `breakeven_nights()` | Nights a month needed to beat the long-term rent, with an estimate of nights a typical listing gets |
| `run_app()` | Opens the app |

**Data**, cleaned from public sources:

| Dataset | What it holds |
|------------------------------------|------------------------------------|
| `vic_listings` | One row per Airbnb listing, matched to a town and zone |
| `vic_reviews_monthly` | Guest reviews by place and month, used as a stand-in for bookings |
| `vic_rents` | Homes Victoria median weekly rents by council area and dwelling type |
| `vic_places` | The town centres used to group listings |

## Installation

``` r
# install.packages("remotes")
remotes::install_github("etc5523-2026/etc5523-assignment-4-devaansh-ops")
```

## Launching the app

``` r
library(staysvic)
run_app()
```

The app reads its data from the installed package, so it works offline once installed.

## A quick example

``` r
library(staysvic)

# How seasonal is Torquay compared with the CBD?
seasonal_demand("Torquay")

# Nights a month a 3 bedroom house in Geelong needs to beat the median rent
breakeven_nights("Geelong", bedrooms = 3)

# Places with no published rent need your own figure
breakeven_nights("Port Campbell", bedrooms = 2, weekly_rent = 550)
```

## Where the data comes from

- **Inside Airbnb**, <https://insideairbnb.com/get-the-data/>. Listings and reviews for Melbourne, the Mornington Peninsula and Barwon South West, which covers Geelong and the Great Ocean Road. Licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).
- **Homes Victoria Rental Report**, moving annual rents by suburb group, <https://discover.data.vic.gov.au/dataset/rental-report-quarterly-moving-annual-rents-by-suburb>. Licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

The scripts in `data-raw/` download and clean both sources from scratch. See `data-raw/README.md` for the order to run them in.

A short stay here means a stay of under 28 nights, which is the definition Victoria's short stay levy uses.

## Limitations

- Homes Victoria does not publish a median rent for every area. Small towns such as Lorne and Port Campbell have too few long-term rentals, so they have no figure. For those places, `breakeven_nights()` returns `NA` for the rent unless you supply your own with `weekly_rent`, and the app asks you to type one in.
- Airbnb does not publish bookings, so demand is estimated from guest reviews. Not every guest reviews, so the counts show the pattern through the year rather than exact numbers.
- Inside Airbnb offers one year of free snapshots. Each listing's settings come from the newest snapshot.
- There is no open, current dataset of hotel bookings for Victorian towns, so the app cannot compare Airbnb with hotels directly.

## AI-use declaration

I used Claude (Anthropic) while working on this assignment. It helped me compare possible datasets that i could use, check data licences and Victoria's definition of a short stay, draft the `data-raw` scripts, the tests and helped with some parts in vignette.

I chose the datasets, and decided which towns and comparisons to include. I ran the data scripts on the real data, checked the outputs, reviewed and edited the code and text. I am responsible for the final submission.

## Licence

MIT. See `LICENSE.md`. The bundled data keeps its original CC BY 4.0 licence and attribution.
