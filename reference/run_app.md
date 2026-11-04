# Launch the City or Coast app

Opens the Shiny app that comes with the package. The app helps someone
thinking about running a short stay compare the Melbourne CBD with the
Great Ocean Road, the Mornington Peninsula, Geelong and other towns. It
uses the data stored inside the package, so it works offline.

## Usage

``` r
run_app(...)
```

## Arguments

- ...:

  Passed on to
  [`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html), for
  example `launch.browser = TRUE` or `port = 4321`.

## Value

Called for its side effect of starting the app. Returns the value of
[`shiny::runApp()`](https://rdrr.io/pkg/shiny/man/runApp.html)
invisibly.

## Examples

``` r
if (interactive()) {
  run_app()
}
```
