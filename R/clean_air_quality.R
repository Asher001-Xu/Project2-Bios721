# Clean one annual RDU air quality CSV.
# path: Path to a CSV with dates, pollutant concentrations, and units.
# ozone_units: Output O3 units, either "ppm" (default) or "ppb".
# Returns: A data frame sorted by date, with one row per observed day.
clean_air_quality <- function(path, ozone_units = "ppm") {
  stopifnot(length(ozone_units) == 1L, ozone_units %in% c("ppm", "ppb"))
  raw <- read.csv(path, check.names = FALSE, na.strings = c("", "NA"))
  names(raw) <- trimws(names(raw))
  fields <- c(co = "Daily Max 8-hour CO Concentration",
              pm25 = "Daily Mean PM2.5 Concentration",
              o3 = "Daily Max 8-hour Ozone Concentration")
  unit_fields <- c(units_CO = "ppm", units_PM = "ug/m3 LC", units_O3 = "ppm")
  stopifnot(all(c("Date", fields, names(unit_fields)) %in% names(raw)))
  for (field in names(unit_fields)) {
    units <- trimws(raw[[field]])
    stopifnot(all(is.na(units) | units == unit_fields[[field]]))
  }

  daily <- raw[c("Date", unname(fields))]
  names(daily) <- c("date", names(fields))
  daily$date <- as.Date(daily$date, format = "%m/%d/%Y")
  stopifnot(!anyNA(daily$date), nrow(daily) > 0L)

  # Deduplicate raw readings before recoding. Clipping can create new ties.
  daily <- unique(daily)
  for (pollutant in names(fields)) {
    values <- daily[[pollutant]]
    stopifnot(is.numeric(values) || all(is.na(values)))
    daily[[pollutant]] <- pmax(as.numeric(values), 0)
  }

  # Group by date and preserve dates with no valid measurement for a pollutant.
  daily <- aggregate(daily[names(fields)], list(date = daily$date), function(x) {
    if (all(is.na(x))) NA_real_ else mean(x, na.rm = TRUE)
  })
  if (ozone_units == "ppb") daily$o3 <- daily$o3 * 1000
  daily
}
