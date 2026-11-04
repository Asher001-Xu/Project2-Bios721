# Daily Air Quality at Raleigh Durham International Airport

BIOS 721 Project 2 explores daily CO, PM2.5, and ozone concentrations as background for a study of air pollution and sickle cell disease in Durham County, North Carolina.

**Author** Tianyu Xu  
**Date** November 4, 2026

## Data source

The three course-provided CSV files contain EPA monitoring data from the Raleigh–Durham International Airport monitor. They cover calendar years 2018 and 2019 and January through April 2020.

## Project files

- `Project2.Rproj` opens the RStudio project.
- `data/` contains the three original annual CSVs.
- `R/clean_air_quality.R` contains the annual cleaning function.
- `R/build_results.R` combines the cleaned data and generates the tables and figures.
- `_quarto.yml` identifies the Quarto report to render.
- `report.qmd` contains the report narrative and references to the generated tables and figures.
- `report.docx` is the rendered Word report.

## Reproduce the report

1. Install R and Quarto. The analysis uses base R and its standard packages. No additional R packages are required.
2. Open `Project2.Rproj` and ensure both `Rscript` and `quarto` are on your terminal PATH.
3. From the project root, run `Rscript R/build_results.R` to regenerate tables and figures in `_results/`.

4. Run `quarto render report.qmd` to write the Word report.

[GitHub repository](https://github.com/Asher001-Xu/Project2-Bios721)

