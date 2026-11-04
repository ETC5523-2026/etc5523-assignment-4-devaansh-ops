# 03_rents.R
# Cleans the Homes Victoria moving annual rents file into `vic_rents`:
# the latest median weekly rent for each LGA and dwelling type.
#
# The spreadsheet has one sheet per dwelling type (for example
# "2 bedroom flat" or "3 bedroom house"). Each sheet has a row of quarter
# labels, a row underneath saying "Count" and "Median" for each quarter, then
# one row per area. Rather than trusting fixed row numbers, this script looks
# for the row that contains "Median" and works outwards from there.

library(dplyr)
library(readxl)

path <- "data-raw/raw/rents_lga.xlsx"

# Download the newest LGA rent file if it is not already here, so this
# script can be run on its own.
if (!file.exists(path)) {
  dir.create("data-raw/raw", showWarnings = FALSE, recursive = TRUE)
  pkg <- jsonlite::fromJSON(
    "https://discover.data.vic.gov.au/api/3/action/package_show?id=rental-report-quarterly-moving-annual-rents-by-suburb"
  )
  res <- pkg$result$resources
  res <- res[grepl("LGA", res$name, ignore.case = TRUE) &
               grepl("xls", res$format, ignore.case = TRUE), ]
  stamp <- ifelse(is.na(res$created), res$last_modified, res$created)
  res <- res[order(stamp, decreasing = TRUE), ]
  message("Using rent file: ", trimws(res$name[1]))
  utils::download.file(res$url[1], path, mode = "wb")
  writeLines(c(trimws(res$name[1]), res$url[1]), "data-raw/raw/rents_source.txt")
}
source_name <- readLines("data-raw/raw/rents_source.txt")[1]

parse_sheet <- function(sheet) {
  x <- read_excel(path, sheet = sheet, col_names = FALSE, .name_repair = "minimal")
  x <- as.data.frame(x)
  cells <- as.matrix(x)

  header_row <- which(apply(cells, 1, function(r) any(grepl("^\\s*Median\\s*$", r))))[1]
  if (is.na(header_row)) return(NULL)

  median_cols <- which(grepl("^\\s*Median\\s*$", cells[header_row, ]))
  latest_col  <- max(median_cols)

  # Quarter label sits above the Count/Median pair, often only on the Count
  # column, so look one or two columns to the left as well.
  label_row <- cells[header_row - 1, ]
  quarter <- NA_character_
  for (j in latest_col:max(1, latest_col - 2)) {
    if (!is.na(label_row[j]) && nzchar(label_row[j])) { quarter <- label_row[j]; break }
  }

  body <- cells[(header_row + 1):nrow(cells), , drop = FALSE]
  # The area name is the right-most filled text cell before the first data column
  name_cols <- seq_len(min(median_cols) - 2)
  area <- apply(body[, name_cols, drop = FALSE], 1, function(r) {
    r <- r[!is.na(r) & nzchar(trimws(r))]
    if (length(r) == 0) NA_character_ else trimws(r[length(r)])
  })

  tibble::tibble(
    dwelling = trimws(sheet),
    lga = area,
    quarter = quarter,
    median_weekly_rent = suppressWarnings(as.numeric(gsub("[$,]", "", body[, latest_col])))
  ) |>
    filter(!is.na(lga), !is.na(median_weekly_rent))
}

sheets <- excel_sheets(path)
sheets <- sheets[grepl("bedroom", sheets, ignore.case = TRUE)]
if (length(sheets) == 0) {
  stop("No sheets with 'bedroom' in their name. Open ", path,
       " and check the sheet names.")
}

vic_rents <- bind_rows(lapply(sheets, parse_sheet)) |>
  mutate(
    bedrooms = as.integer(sub("^\\s*(\\d).*", "\\1", dwelling)),
    dwelling_type = ifelse(grepl("house", dwelling, ignore.case = TRUE), "House", "Flat"),
    # Excel sometimes turns quarter labels into date serial numbers
    quarter = ifelse(grepl("^\\d{5}$", quarter),
                     format(as.Date(as.numeric(quarter), origin = "1899-12-30"), "%b %Y"),
                     quarter),
    source = source_name
  ) |>
  select(lga, bedrooms, dwelling_type, median_weekly_rent, quarter, source)

if (nrow(vic_rents) == 0) stop("Parsed no rents. The spreadsheet layout may have changed.")
message(nrow(vic_rents), " rent rows from ", length(unique(vic_rents$lga)), " areas")

usethis::use_data(vic_rents, overwrite = TRUE)
