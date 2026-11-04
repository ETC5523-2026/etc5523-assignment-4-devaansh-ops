# 00_places.R
# Builds `vic_places`, the lookup table of towns that listings are matched to.
#
# Inside Airbnb only records the local government area (LGA) of each listing.
# An LGA like Surf Coast covers Torquay, Anglesea and Lorne, which behave very
# differently, so listings are also matched to the nearest town centre below.
# A listing belongs to a town if it sits within `radius_km` of that town's
# centre. Anything further away falls back to its LGA (for example
# "Rest of Surf Coast").
#
# Town centres are approximate coordinates of each town's main street,
# rounded to three decimal places. The radii were chosen by hand so that
# neighbouring towns do not swallow each other.

library(dplyr)
library(tibble)

vic_places <- tribble(
  ~place,            ~zone,                    ~lat,     ~long,    ~radius_km,
  # The baseline everything is compared with
  "Melbourne CBD",   "Melbourne CBD",          -37.814,  144.963,  1.5,

  # Great Ocean Road, east to west
  "Torquay",         "Great Ocean Road",       -38.331,  144.326,  4,
  "Anglesea",        "Great Ocean Road",       -38.407,  144.186,  3,
  "Aireys Inlet",    "Great Ocean Road",       -38.460,  144.103,  3,
  "Lorne",           "Great Ocean Road",       -38.542,  143.977,  3,
  "Wye River",       "Great Ocean Road",       -38.634,  143.889,  3,
  "Apollo Bay",      "Great Ocean Road",       -38.757,  143.671,  4,
  "Port Campbell",   "Great Ocean Road",       -38.619,  142.995,  4,
  "Warrnambool",     "Great Ocean Road",       -38.383,  142.483,  5,
  "Port Fairy",      "Great Ocean Road",       -38.385,  142.237,  4,

  # Geelong and the Bellarine Peninsula
  "Geelong",         "Geelong and Bellarine",  -38.149,  144.360,  5,
  "Barwon Heads",    "Geelong and Bellarine",  -38.273,  144.491,  2,
  "Ocean Grove",     "Geelong and Bellarine",  -38.265,  144.520,  3,
  "Queenscliff",     "Geelong and Bellarine",  -38.267,  144.662,  3,
  "Portarlington",   "Geelong and Bellarine",  -38.115,  144.655,  3,

  # Mornington Peninsula
  "Portsea",         "Mornington Peninsula",   -38.320,  144.712,  2,
  "Sorrento",        "Mornington Peninsula",   -38.339,  144.741,  3,
  "Rye",             "Mornington Peninsula",   -38.372,  144.823,  3,
  "Rosebud",         "Mornington Peninsula",   -38.355,  144.906,  3,
  "Dromana",         "Mornington Peninsula",   -38.334,  144.965,  3,
  "Mount Martha",    "Mornington Peninsula",   -38.267,  145.015,  3,
  "Mornington",      "Mornington Peninsula",   -38.218,  145.038,  4,
  "Red Hill",        "Mornington Peninsula",   -38.380,  145.020,  3,
  "Flinders",        "Mornington Peninsula",   -38.474,  145.019,  3,

  # Inner Melbourne and the hills, for city-fringe comparisons
  "St Kilda",        "Inner Melbourne",        -37.868,  144.981,  1.5,
  "Healesville",     "Yarra Valley and Dandenongs", -37.654, 145.517, 4,
  "Olinda",          "Yarra Valley and Dandenongs", -37.858, 145.367, 3,
  "Warburton",       "Yarra Valley and Dandenongs", -37.753, 145.689, 3
)

# Zone for listings that did not match any town, decided by their LGA.
# Keys are LGA names in lower case with everything but letters removed,
# so "Colac-Otway", "Colac Otway" and "Colac Otway Shire" all match.
lga_zones <- tribble(
  ~lga_key,               ~zone,
  "melbourne",            "Inner Melbourne",
  "portphillip",          "Inner Melbourne",
  "yarra",                "Inner Melbourne",
  "stonnington",          "Inner Melbourne",
  "surfcoast",            "Great Ocean Road",
  "colacotway",           "Great Ocean Road",
  "corangamite",          "Great Ocean Road",
  "warrnambool",          "Great Ocean Road",
  "moyne",                "Great Ocean Road",
  "greatergeelong",       "Geelong and Bellarine",
  "queenscliffe",         "Geelong and Bellarine",
  "morningtonpeninsula",  "Mornington Peninsula",
  "yarraranges",          "Yarra Valley and Dandenongs"
)

saveRDS(lga_zones, "data-raw/lga_zones.rds")
usethis::use_data(vic_places, overwrite = TRUE)
