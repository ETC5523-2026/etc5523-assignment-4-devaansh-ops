test_that("seasonal_demand index averages to 1 for each place", {
  d <- seasonal_demand("Lorne")
  skip_if(nrow(d) == 0, "No Lorne reviews in this snapshot")
  means <- tapply(d$index, d$place, mean)
  expect_equal(as.numeric(means), rep(1, length(means)), tolerance = 1e-8)
  expect_true("Melbourne CBD" %in% d$place)
  expect_true(all(d$month %in% 1:12))
})

test_that("seasonal_demand rejects a stay type that does not exist", {
  expect_error(seasonal_demand("Lorne", stay_type = "Weekend"), "stay_type")
})

test_that("seasonal_demand returns an empty tibble for an unknown place", {
  d <- seasonal_demand("Atlantis", baseline = NULL)
  expect_equal(nrow(d), 0)
  expect_named(d, c("place", "month", "month_label", "avg_reviews", "index",
                    "total_reviews", "enough_data"))
})

test_that("host_mix shares add up to 1 within each place", {
  h <- host_mix("Torquay")
  sums <- tapply(h$share, h$place, sum)
  expect_equal(as.numeric(sums), rep(1, length(sums)), tolerance = 1e-8)
})

test_that("breakeven_nights follows the documented formula", {
  b <- breakeven_nights("Melbourne CBD", bedrooms = 1, weekly_rent = 600, costs = 0.2)
  skip_if(is.na(b$median_price), "No 1 bedroom CBD prices in this snapshot")
  expected <- (600 * 52 / 12) / (b$median_price * 0.8)
  expect_equal(b$nights_needed, expected)
  expect_equal(b$rent_source, "Your figure")
})

test_that("breakeven_nights explains itself when there is no data", {
  b <- breakeven_nights("Atlantis", bedrooms = 2, weekly_rent = 500)
  expect_false(b$reliable)
  expect_match(b$note, "no active")
})

test_that("breakeven_nights checks its inputs", {
  expect_error(breakeven_nights("Lorne", bedrooms = 7), "bedrooms")
  expect_error(breakeven_nights("Lorne", bedrooms = 2, costs = 1.5), "costs")
})
