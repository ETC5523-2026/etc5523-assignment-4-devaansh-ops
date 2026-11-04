#' Launch the City or Coast app
#'
#' Opens the Shiny app that comes with the package. The app helps someone
#' thinking about running a short stay compare the Melbourne CBD with the
#' Great Ocean Road, the Mornington Peninsula, Geelong and other towns.
#' It uses the data stored inside the package, so it works offline.
#'
#' @param ... Passed on to [shiny::runApp()], for example
#'   `launch.browser = TRUE` or `port = 4321`.
#'
#' @return Called for its side effect of starting the app. Returns the value
#'   of [shiny::runApp()] invisibly.
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
#' @export
run_app <- function(...) {
  app_dir <- system.file("app", package = "staysvic")
  if (app_dir == "") {
    stop("Could not find the app. Try reinstalling staysvic.", call. = FALSE)
  }
  invisible(shiny::runApp(app_dir, display.mode = "normal", ...))
}
