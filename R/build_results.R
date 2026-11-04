source("R/clean_air_quality.R")

# Combine the daily records and derive calendar groups from the cleaned dates.
files <- file.path("data", paste0("AQ_", 2018:2020, ".csv"))
daily <- do.call(rbind, lapply(files, clean_air_quality))
stopifnot(!anyDuplicated(daily$date))
daily$year <- as.integer(format(daily$date, "%Y"))
daily$month <- as.integer(format(daily$date, "%m"))

dir.create("_results", showWarnings = FALSE)
labels <- c(co = "CO (ppm)", pm25 = "PM2.5 (ug/m3 LC)", o3 = "Ozone (ppm)")
for (year in 2018:2020) {
  values <- daily[daily$year == year, names(labels)]
  minima <- vapply(values, min, numeric(1), na.rm = TRUE)
  maxima <- vapply(values, max, numeric(1), na.rm = TRUE)
  writeLines(c(
    "| Pollutant and unit | Minimum | Maximum |",
    "|:-------------------|--------:|--------:|",
    sprintf("| %s | %.3f | %.3f |", labels, minima, maxima)
  ), file.path("_results", paste0("table-", year, ".md")))
}

# The confidence interval uses the number of observed days for each pollutant.
month_summary <- function(values) {
  groups <- split(values, factor(daily$month, levels = 1:12))
  t(vapply(groups, function(x) {
    x <- x[!is.na(x)]
    n <- length(x)
    average <- mean(x)
    margin <- 1.96 * sd(x) / sqrt(n)
    c(mean = average, lower = average - margin, upper = average + margin)
  }, numeric(3)))
}

# Keep month positions and grid styling consistent across the figures.
month_axes <- function(limits, y_label, heading, axis_cex = 1, month_angle = 1) {
  plot(NA, xlim = c(1, 12), ylim = limits, xlab = "", ylab = y_label,
       main = heading, xaxt = "n", yaxt = "n", bty = "n")
  ticks <- pretty(limits, n = 4)
  abline(h = ticks, col = "#E2E8F0")
  axis(2, at = ticks, las = 1, tck = 0, cex.axis = axis_cex)
  axis(1, at = 1:12, labels = month.abb, tck = 0, cex.axis = axis_cex, las = month_angle)
}

png("_results/co-ozone.png", width = 6.3, height = 2.85, units = "in", res = 240)
par(mfrow = c(1, 2), mar = c(2.5, 4, 2.1, 0.6), mgp = c(2.45, 0.55, 0))
colors <- c(co = "#14668B", o3 = "#A04824")
for (pollutant in names(colors)) {
  summary <- month_summary(daily[[pollutant]])
  month_axes(range(summary[, c("lower", "upper")]), labels[[pollutant]],
             c(co = "Carbon monoxide", o3 = "Ozone")[[pollutant]], 0.82, 2)
  arrows(1:12, summary[, "lower"], 1:12, summary[, "upper"],
         angle = 90, code = 3, length = 0.035, col = colors[[pollutant]], lwd = 1.5)
  points(1:12, summary[, "mean"], pch = 19, col = colors[[pollutant]])
}
invisible(dev.off())

# Connect consecutive monthly PM2.5 means within each year.
pm_monthly <- aggregate(pm25 ~ year + month, daily, mean)
png("_results/pm25.png", width = 6.3, height = 2.85, units = "in", res = 240)
par(mar = c(2.1, 4, 1.1, 0.6), mgp = c(2.5, 0.55, 0))
month_axes(c(4, 12), labels[["pm25"]], "")
year_colors <- c("#14668B", "#A04824", "#36734F")
year_symbols <- c(19, 17, 15)
for (i in seq_along(year_colors)) {
  values <- pm_monthly[pm_monthly$year == 2017 + i, ]
  lines(values$month, values$pm25, type = "o", lwd = 1.8,
        col = year_colors[i], pch = year_symbols[i])
}
legend("top", legend = 2018:2020, col = year_colors, pch = year_symbols,
       lty = 1, lwd = 1.8, horiz = TRUE, bty = "n", cex = 0.88)
invisible(dev.off())

