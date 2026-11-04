# City or Coast? A Shiny app for the staysvic package.
#
# Who it is for: someone thinking about buying or converting a property
# to run as a short stay in Victoria.
# The question: should I run a short stay in the city or on the coast,
# and when does it actually pay off?
#
# All data comes from the installed package (vic_listings,
# vic_reviews_monthly, vic_rents). Nothing is read from disk at run time.

library(shiny)
library(bslib)
library(ggplot2)
library(staysvic)

# ---- Colours and theme -----------------------------------------------------

col <- list(
  ink   = "#1B2A3A",  # text and the CBD baseline
  ocean = "#1F6F8B",  # main accent
  sand  = "#F4EDE1",  # page background
  card  = "#FFFFFF",
  muted = "#6B7785",
  coral = "#D9644A"   # warnings and the break-even line
)
place_cols <- c("#1F6F8B", "#D9644A", "#E0A526", "#5B8C5A")

theme_app <- bs_theme(
  version = 5,
  bg = col$sand, fg = col$ink, primary = col$ocean, secondary = col$muted,
  danger = col$coral,
  base_font = font_collection(font_google("Source Sans 3", local = FALSE),
                              "system-ui", "sans-serif"),
  heading_font = font_collection(font_google("Fraunces", local = FALSE),
                                 "Georgia", "serif"),
  "card-bg" = col$card,
  "card-border-color" = "#E4DACB"
) |>
  bs_add_rules("
    .navbar { background-color: #1B2A3A !important; }
    .navbar, .navbar .navbar-brand, .navbar .nav-link { color: #F4EDE1 !important; }
    .navbar .navbar-brand { font-family: Fraunces, Georgia, serif; font-size: 1.4rem; }
    .navbar .nav-link.active { color: #FFFFFF !important;
                               border-bottom: 3px solid #E0A526; }
    .card { box-shadow: 0 1px 3px rgba(27,42,58,0.06); }
    .question { font-size: 1.35rem; line-height: 1.4; }
    .help-note { color: #6B7785; font-size: 0.95rem; }
    .read-this { border-left: 4px solid #1F6F8B; background: #EEF5F7;
                 padding: 0.75rem 1rem; border-radius: 4px; }
    .weak { border-left: 4px solid #D9644A; background: #FBEDE9;
            padding: 0.75rem 1rem; border-radius: 4px; }
    .bslib-value-box .value-box-value { font-size: 1.9rem; }
    table.fields td { padding: 0.35rem 0.6rem; vertical-align: top; }
  ")

ggtheme <- theme_minimal(base_size = 14) +
  theme(panel.grid.minor = element_blank(),
        panel.grid.major.x = element_blank(),
        plot.title.position = "plot",
        legend.position = "top",
        legend.title = element_blank(),
        text = element_text(colour = col$ink),
        axis.text = element_text(colour = col$muted))

# ---- Choices ---------------------------------------------------------------

short <- "Short stay (under 28 nights)"
baseline <- "Melbourne CBD"

active <- vic_listings[vic_listings$active, ]
counts <- table(active$place)
big_enough <- names(counts)[counts >= 20]
place_zone <- unique(active[active$place %in% big_enough & active$place != baseline,
                            c("place", "zone")])
zone_order <- c("Geelong and Bellarine", "Great Ocean Road", "Mornington Peninsula",
                "Yarra Valley and Dandenongs", "Inner Melbourne")
place_zone$zone <- factor(place_zone$zone,
                          levels = unique(c(zone_order, sort(unique(place_zone$zone)))))
place_zone <- place_zone[order(place_zone$zone, place_zone$place), ]
place_choices <- split(place_zone$place, droplevels(place_zone$zone))

pick_defaults <- function(wanted, n) {
  hits <- intersect(wanted, place_zone$place)
  if (length(hits) == 0) hits <- utils::head(place_zone$place, n)
  utils::head(hits, n)
}
default_places <- pick_defaults(c("Geelong", "Port Campbell", "Sorrento"), 3)
default_one <- pick_defaults(c("Geelong", "Torquay", "Sorrento"), 1)

# Small inline icons so the app does not need an icon package
icon_house <- function() HTML('<svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><path d="M3 11l9-7 9 7v9a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/></svg>')
icon_building <- function() HTML('<svg width="34" height="34" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><rect x="5" y="3" width="14" height="18" rx="1"/><path d="M9 7h2M13 7h2M9 11h2M13 11h2M9 15h2M13 15h2"/></svg>')

how_to_read <- function(...) div(class = "read-this", tags$strong("How to read this. "), ...)

# ---- UI --------------------------------------------------------------------

ui <- page_navbar(
  title = "City or Coast?",
  theme = theme_app,
  bg = col$ink,
  inverse = TRUE,
  fillable = FALSE,

  # Start here ---------------------------------------------------------------
  nav_panel(
    "Start here",
    layout_columns(
      col_widths = c(7, 5),
      card(
        card_header("What this app is for"),
        p(class = "question",
          "Should I run a short stay in the Melbourne CBD or on the coast, and when does it actually pay off?"),
        p(tags$strong("Who it is for. "),
          "Someone thinking about buying a property, or converting one they own, to rent out on Airbnb.",
          "Maybe a unit near the city, maybe a holiday house in Lorne or Sorrento."),
        p("The CBD is always on the charts as a baseline, because it is the market most people know.",
          "Every coastal or regional town is compared against it."),
        p(tags$strong("Three tabs, three questions.")),
        tags$ol(
          tags$li(tags$strong("When is it busy? "), "Is demand steady all year, or does it come in a summer rush?"),
          tags$li(tags$strong("Who runs it? "), "Are you competing with locals renting out a spare home, or with management companies?"),
          tags$li(tags$strong("Does it pay? "), "How many booked nights a month you would need to earn more than a normal lease.")
        )
      ),
      card(
        card_header("Words used in this app"),
        tags$table(
          class = "fields",
          tags$tr(tags$td(tags$strong("Short stay")),
                  tags$td("A listing that accepts stays under 28 nights. This is the line Victoria's short stay levy uses.")),
          tags$tr(tags$td(tags$strong("Mid stay")),
                  tags$td("A listing with a minimum stay of 28 nights or more. These hosts use Airbnb more like a rental site.")),
          tags$tr(tags$td(tags$strong("Entire home")),
                  tags$td("The guest gets the whole house or unit to themselves.")),
          tags$tr(tags$td(tags$strong("Active listing")),
                  tags$td("A listing that got at least one guest review in the last 12 months.")),
          tags$tr(tags$td(tags$strong("Demand")),
                  tags$td("Counted with guest reviews, since Airbnb does not publish bookings. Not every guest reviews, so this shows the pattern, not exact numbers.")),
          tags$tr(tags$td(tags$strong("Place")),
                  tags$td("A town. Listings within a few kilometres of the town centre count towards it."))
        )
      )
    ),
    card(
      class = "help-note",
      p("Data: Inside Airbnb (Melbourne, Mornington Peninsula and Barwon South West snapshots) and the Homes Victoria Rental Report.",
        "Both are licensed under CC BY 4.0. Snapshot date: ",
        tags$strong(format(max(vic_listings$snapshot), "%d %B %Y")), ".")
    )
  ),

  # When is it busy? ---------------------------------------------------------
  nav_panel(
    "When is it busy?",
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        selectizeInput("places", "Places to compare with the CBD",
                       choices = place_choices, selected = default_places,
                       multiple = TRUE, options = list(maxItems = 4)),
        p(class = "help-note", "Pick up to four towns. Type to search."),
        radioButtons("stay", "Type of listing",
                     choices = c("Short stays" = short,
                                 "Mid stays" = "Mid stay (28 nights or more)",
                                 "Both" = "All")),
        radioButtons("room", "What the guest gets",
                     choices = c("Entire home" = "Entire home/apt",
                                 "Private room" = "Private room",
                                 "Anything" = "All"))
      ),
      card(
        card_header("Demand through the year, compared with the CBD"),
        plotOutput("season_plot", height = "420px"),
        uiOutput("season_warning"),
        how_to_read(
          "Each line shows how busy a month is compared with that place's own average month.",
          "A value of 2 means twice as busy as usual. A value of 0.5 means half as busy.",
          "The dashed grey line is the Melbourne CBD. If a town's line climbs far above it in summer",
          "and dips far below it in winter, that town earns most of its money in a few months."
        )
      ),
      card(
        card_header("Busiest and quietest months"),
        tableOutput("season_table"),
        p(class = "help-note",
          "The swing is the busiest month divided by the quietest. The bigger it is, the more seasonal the place.")
      )
    )
  ),

  # Who runs it? -------------------------------------------------------------
  nav_panel(
    "Who runs it?",
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        selectInput("host_place", "Place", choices = place_choices, selected = default_one),
        p(class = "help-note",
          "Compares who runs the active listings in this place with who runs them in the CBD.")
      ),
      layout_columns(
        value_box("Run by single-listing hosts", textOutput("vb_single"),
                  theme = "primary", showcase = icon_house()),
        value_box("Hotel rooms or serviced apartments", textOutput("vb_hotel"),
                  theme = "secondary", showcase = icon_building())
      ),
      card(
        card_header("Share of listings by host size"),
        plotOutput("host_plot", height = "300px"),
        uiOutput("host_warning"),
        how_to_read(
          "Each bar adds up to 100 per cent of active listings in that place.",
          "Single-listing hosts are usually owners renting out their own place.",
          "Hosts with 10 or more listings are almost always management companies.",
          "A place where the dark section is large is a professional market, which is harder for a newcomer to compete in on price and reviews."
        )
      ),
      card(
        card_header("Biggest operators in this place"),
        tableOutput("operator_table"),
        p(class = "help-note",
          "Only hosts with 10 or more listings across Victoria are named. Smaller hosts are private people and are not shown.")
      )
    )
  ),

  # Does it pay? -------------------------------------------------------------
  nav_panel(
    "Does it pay?",
    layout_sidebar(
      sidebar = sidebar(
        width = 300,
        selectInput("be_place", "Place",
                    choices = c(list("Melbourne CBD" = baseline), place_choices),
                    selected = default_one),
        selectInput("be_beds", "Bedrooms",
                    choices = c("1" = 1, "2" = 2, "3" = 3, "4 or more" = 4),
                    selected = 2),
        numericInput("rent", "Weekly rent on a normal lease ($)", value = NA,
                     min = 50, max = 5000, step = 10),
        p(class = "help-note", textOutput("rent_source", inline = TRUE)),
        sliderInput("costs", "Costs as a share of each night's price",
                    min = 0, max = 0.5, value = 0.2, step = 0.05),
        p(class = "help-note",
          "Platform fees, cleaning, linen and any manager. 20 per cent is a common starting guess.")
      ),
      uiOutput("be_warning"),
      layout_columns(
        value_box("Typical nightly price", textOutput("vb_price"), theme = "primary"),
        value_box("Nights needed each month", textOutput("vb_needed"), theme = "danger"),
        value_box("Nights a typical listing gets", textOutput("vb_typical"), theme = "secondary")
      ),
      card(
        card_header("Estimated booked nights each month against the break-even line"),
        plotOutput("be_plot", height = "380px"),
        how_to_read(
          "The bars estimate how many nights a typical whole-home listing in this place was booked in each month of the last year.",
          "The red line is how many nights you would need to match the rent from a normal lease.",
          "Months where the bars clear the line are months a short stay beats renting. Months below it are months you would lose out.",
          "Change the rent or costs to see how sensitive the answer is."
        )
      )
    )
  )
)

# ---- Server ----------------------------------------------------------------

server <- function(input, output, session) {

  # When is it busy? ---------------------------------------------------------

  # input$places, input$stay and input$room all feed this one reactive.
  # It calls seasonal_demand() from the package, and both the chart and the
  # table below read from it, so the work is done once per change.
  demand <- reactive({
    validate(need(length(input$places) > 0,
                  "Pick at least one place in the sidebar to compare with the CBD."))
    seasonal_demand(input$places, stay_type = input$stay, room_type = input$room)
  })

  output$season_plot <- renderPlot({
    d <- demand()
    validate(need(nrow(d) > 0,
                  "No reviews match these settings. Try 'Both' listing types or 'Anything' for what the guest gets."))
    towns <- d[d$place != baseline, ]
    cbd <- d[d$place == baseline, ]
    ggplot(towns, aes(month_label, index, colour = place, group = place)) +
      geom_hline(yintercept = 1, colour = "#C9BFAF") +
      geom_line(data = cbd, linetype = "dashed", colour = col$muted, linewidth = 1) +
      geom_point(data = cbd, colour = col$muted, size = 1.8) +
      geom_line(linewidth = 1.3) +
      geom_point(size = 2.4) +
      scale_colour_manual(values = place_cols) +
      scale_y_continuous(labels = function(x) paste0(x, "x")) +
      labs(x = NULL, y = "Compared with an average month",
           subtitle = "Dashed grey line: Melbourne CBD") +
      ggtheme
  }, res = 96)

  output$season_warning <- renderUI({
    d <- demand()
    missing <- setdiff(input$places, d$place)
    thin <- unique(d$place[!d$enough_data])
    if (length(missing) > 0) {
      return(div(class = "weak",
                 tags$strong("No reviews for: "), paste(missing, collapse = ", "), ". ",
                 "Nobody reviewed a listing like this there in the last three years, so it is left off the chart. ",
                 "Try 'Both' listing types or 'Anything' for what the guest gets."))
    }
    if (length(thin) == 0) return(NULL)
    div(class = "weak",
        tags$strong("Not much data for: "), paste(thin, collapse = ", "), ". ",
        "These places have fewer than 100 reviews with these settings, so one busy weekend can look like a trend. ",
        "Read their lines as a rough sketch.")
  })

  output$season_table <- renderTable({
    d <- demand()
    validate(need(nrow(d) > 0, ""))
    out <- lapply(split(d, d$place), function(p) {
      data.frame(
        Place = p$place[1],
        `Busiest month` = as.character(p$month_label[which.max(p$index)]),
        `Quietest month` = as.character(p$month_label[which.min(p$index)]),
        Swing = if (min(p$index) > 0) sprintf("%.1f times", max(p$index) / min(p$index)) else "No reviews in some months",
        `Reviews counted` = format(p$total_reviews[1], big.mark = ","),
        check.names = FALSE
      )
    })
    out <- do.call(rbind, out)
    out[order(out$Place != baseline), ]
  }, striped = TRUE, width = "100%")

  # Who runs it? -------------------------------------------------------------

  hosts <- reactive({
    req(input$host_place)
    host_mix(input$host_place)
  })

  output$vb_single <- renderText({
    h <- hosts()
    h <- h[h$place == input$host_place & h$host_tier == "Single listing", ]
    if (nrow(h) == 0) "No data" else scales::percent(h$share, accuracy = 1)
  })

  output$vb_hotel <- renderText({
    h <- hosts()
    h <- h[h$place == input$host_place, ]
    if (nrow(h) == 0) "No data" else scales::percent(h$hotel_share[1], accuracy = 1)
  })

  output$host_plot <- renderPlot({
    h <- hosts()
    validate(need(nrow(h) > 0, "There are no active listings in this place."))
    h$label <- paste0(h$place, "\n(", h$total, " listings)")
    h$label <- factor(h$label, levels = rev(unique(h$label)))
    ggplot(h, aes(share, label, fill = host_tier)) +
      geom_col(width = 0.6) +
      scale_fill_manual(values = c("Single listing" = "#9CC5D1",
                                   "2 to 9 listings" = "#1F6F8B",
                                   "10 or more listings" = col$ink)) +
      scale_x_continuous(labels = scales::percent, expand = expansion(mult = c(0, 0.04))) +
      labs(x = NULL, y = NULL) +
      ggtheme +
      theme(panel.grid.major.y = element_blank(),
            panel.grid.major.x = element_line(colour = "#E4DACB"))
  }, res = 96)

  output$host_warning <- renderUI({
    h <- hosts()
    n <- h$total[h$place == input$host_place][1]
    if (is.na(n) || n >= 30) return(NULL)
    div(class = "weak",
        tags$strong("Small market. "),
        input$host_place, " has only ", n, " active listings, so a single operator joining or leaving would shift these shares a lot.")
  })

  output$operator_table <- renderTable({
    ops <- top_operators(input$host_place)
    validate(need(nrow(ops) > 0,
                  "No operator here runs 10 or more listings. This place is run by smaller, mostly private hosts."))
    data.frame(Operator = ops$operator,
               `Listings here` = ops$listings,
               `Share of this place` = scales::percent(ops$share, accuracy = 1),
               `Listings across Victoria` = ops$listings_vic,
               check.names = FALSE)
  }, striped = TRUE, width = "100%")

  # Does it pay? -------------------------------------------------------------

  # When the place or bedrooms change, fill in the Homes Victoria median
  # rent. The user can then type over it with their own figure.
  observeEvent(list(input$be_place, input$be_beds), {
    req(input$be_place, input$be_beds)
    auto <- breakeven_nights(input$be_place, as.integer(input$be_beds))
    updateNumericInput(session, "rent", value = round(auto$weekly_rent))
  })

  be <- reactive({
    req(input$be_place, input$be_beds)
    rent <- if (is.na(input$rent) || input$rent <= 0) NULL else input$rent
    breakeven_nights(input$be_place, as.integer(input$be_beds),
                     weekly_rent = rent, costs = input$costs)
  })

  output$rent_source <- renderText({
    req(input$be_place, input$be_beds)
    auto <- breakeven_nights(input$be_place, as.integer(input$be_beds))
    if (is.na(auto$weekly_rent)) {
      "There is no Homes Victoria rent for this area, so the box is empty. Type your own weekly rent, for example the rent of a similar home nearby."
    } else {
      paste0("Pre-filled from the ", auto$rent_source, ". Type over it to use your own figure.")
    }
  })

  output$be_warning <- renderUI({
    b <- be()
    no_rent <- is.na(input$rent) || input$rent <= 0
    if (no_rent && is.na(b$weekly_rent)) {
      return(div(class = "weak", tags$strong("Add a rent to see the result. "),
                 "Homes Victoria has no rent figure for this place and size. ",
                 "Type a weekly rent in the box on the left (for example, what a similar ",
                 "home nearby rents for) and the break-even line will appear."))
    }
    if (b$reliable) return(NULL)
    div(class = "weak", tags$strong("Heads up. "), b$note)
  })

  dollars <- function(x) if (is.na(x)) "No data" else scales::dollar(x, accuracy = 1)
  nights <- function(x) if (is.na(x)) "No data" else sprintf("%.0f nights", x)

  output$vb_price <- renderText(dollars(be()$median_price))
  output$vb_needed <- renderText({
    n <- be()$nights_needed
    if (!is.na(n) && n > 30) "More than a month" else nights(n)
  })
  output$vb_typical <- renderText(nights(be()$est_nights_avg))

  output$be_plot <- renderPlot({
    b <- be()
    m <- b$monthly[[1]]
    validate(need(nrow(m) > 0,
                  "No reviews for whole-home short stays here in the last year, so there is nothing to estimate from."))
    p <- ggplot(m, aes(month_label, est_nights)) +
      geom_col(fill = col$ocean, width = 0.7) +
      scale_y_continuous(limits = c(0, max(31, b$nights_needed, na.rm = TRUE)),
                         expand = c(0, 0)) +
      labs(x = NULL, y = "Estimated nights booked") +
      ggtheme
    if (!is.na(b$nights_needed)) {
      p <- p +
        geom_hline(yintercept = b$nights_needed, colour = col$coral, linewidth = 1.2) +
        annotate("label", x = 0.6, y = b$nights_needed,
                 label = sprintf("Break-even: %.0f nights", b$nights_needed),
                 hjust = 0, vjust = -0.3, colour = col$coral, fill = "white",
                 size = 4.2)
    }
    p
  }, res = 96)
}

shinyApp(ui, server)
