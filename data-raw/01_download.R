# 01_download.R
# Downloads the raw files into data-raw/raw/. Run this first.
#
# Sources
# 1. Inside Airbnb (https://insideairbnb.com/get-the-data/), CC BY 4.0.
#    Every Victorian region on the page is downloaded, which at the time of
#    writing means Melbourne, Mornington Peninsula and Barwon South West.
#    Barwon South West is the file that covers Geelong, the Bellarine and the
#    Great Ocean Road. The newest snapshot of each region is used.
# 2. Homes Victoria Rental Report, moving annual rents by LGA
#    (https://discover.data.vic.gov.au/dataset/rental-report-quarterly-moving-annual-rents-by-suburb),
#    CC BY 4.0. The newest LGA file listed on the dataset page is used.
#
# The raw files are large (the Melbourne listings file alone is tens of MB),
# so they are kept out of git. Only the cleaned, much smaller objects in
# data/ are committed.

raw_dir <- "data-raw/raw"
dir.create(raw_dir, showWarnings = FALSE, recursive = TRUE)
options(timeout = 900)

# ---- 1. Inside Airbnb ---------------------------------------------------

pattern <- "https://data\\.insideairbnb\\.com/australia/vic/([a-z0-9-]+)/(\\d{4}-\\d{2}-\\d{2})/data/listings\\.csv\\.gz"

# First choice: read the download page and take every Victorian region on it
page <- tryCatch(
  paste(readLines("https://insideairbnb.com/get-the-data/", warn = FALSE), collapse = "\n"),
  error = function(e) ""
)
hits <- regmatches(page, gregexpr(pattern, page))[[1]]

if (length(hits) > 0) {
  snapshots <- unique(data.frame(
    region = sub(pattern, "\\1", hits),
    date   = as.Date(sub(pattern, "\\2", hits))
  ))
} else {
  # Fallback: if the page cannot be read, check the data server directly for
  # the newest snapshot of each known Victorian region, going back 120 days.
  message("Could not read the Inside Airbnb page, so checking the data server directly.")
  exists_url <- function(url) {
    # Use the recorded status code, not the first header line, which can
    # belong to a proxy rather than the data server
    isTRUE(tryCatch(attr(curlGetHeaders(url), "status") == 200, error = function(e) FALSE))
  }
  regions <- c("melbourne", "mornington-peninsula", "barwon-south-west-vic")
  found <- lapply(regions, function(r) {
    for (d in as.character(Sys.Date() - 0:120)) {
      url <- sprintf("https://data.insideairbnb.com/australia/vic/%s/%s/data/listings.csv.gz", r, d)
      if (exists_url(url)) return(data.frame(region = r, date = as.Date(d)))
    }
    NULL
  })
  snapshots <- do.call(rbind, found)
}

if (is.null(snapshots) || nrow(snapshots) == 0) {
  stop("No Victorian regions found. Check https://insideairbnb.com/get-the-data/ by hand.")
}
# Keep only the newest snapshot of each region
snapshots <- snapshots[order(snapshots$region, snapshots$date, decreasing = TRUE), ]
snapshots <- snapshots[!duplicated(snapshots$region), ]
print(snapshots)

for (i in seq_len(nrow(snapshots))) {
  base <- sprintf("https://data.insideairbnb.com/australia/vic/%s/%s",
                  snapshots$region[i], snapshots$date[i])
  files <- c(listings = "data/listings.csv.gz",
             reviews  = "visualisations/reviews.csv")
  for (f in names(files)) {
    dest <- file.path(raw_dir, sprintf("%s_%s_%s%s", snapshots$region[i],
                                       snapshots$date[i], f,
                                       ifelse(f == "listings", ".csv.gz", ".csv")))
    if (!file.exists(dest)) {
      message("Downloading ", base, "/", files[[f]])
      utils::download.file(paste0(base, "/", files[[f]]), dest, mode = "wb")
    }
  }
}

write.csv(snapshots, file.path(raw_dir, "airbnb_snapshots.csv"), row.names = FALSE)

# ---- 2. Homes Victoria rents --------------------------------------------

pkg <- jsonlite::fromJSON(
  "https://discover.data.vic.gov.au/api/3/action/package_show?id=rental-report-quarterly-moving-annual-rents-by-suburb"
)
res <- pkg$result$resources
res <- res[grepl("LGA", res$name, ignore.case = TRUE) &
             grepl("xls", res$format, ignore.case = TRUE), ]
if (nrow(res) == 0) stop("No LGA rent file found on data.vic.gov.au.")

# Newest file first, going by when it was added to the portal
stamp <- ifelse(is.na(res$created), res$last_modified, res$created)
res <- res[order(stamp, decreasing = TRUE), ]
message("Using rent file: ", res$name[1])

utils::download.file(res$url[1], file.path(raw_dir, "rents_lga.xlsx"), mode = "wb")
writeLines(c(res$name[1], res$url[1]), file.path(raw_dir, "rents_source.txt"))
