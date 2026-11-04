#' @keywords internal
"_PACKAGE"

#' @importFrom rlang .data
#' @importFrom bslib bs_theme
#' @importFrom ggplot2 ggplot
#' @importFrom scales percent
NULL

# Column names used inside tidyr::nesting(), which R CMD check cannot see
utils::globalVariables(c("place", "total", "hotel_share", "entire_share",
                         "host_tier"))
