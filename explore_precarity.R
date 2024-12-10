library(dplyr)
library(ggplot2)
library(targets)

tar_load(silc_variable_availability)
tar_load(matches("silc_[0-9]{4}"))

recode_housing_cost_share <- function(df){
  df %>%
    mutate(
      r_income_disposable_month = (income_disposable / 12) %>%
        if_else(. < 0, 0, .),
      r_total_housing_cost = total_housing_cost %>%
        if_else(. < 0, 0, .),
      r_housing_cost_share_income = ((r_total_housing_cost / r_income_disposable_month) * 100) %>%
        if_else(. == Inf, NA_real_, .) %>%
        if_else(. > 200, NA_real_, .) %>%
        if_else(. > 100, 100, .)
    )
}

histograms <- purrr::map(list(
  silc_2012, silc_2014,
  silc_2016, silc_2018,
  silc_2020, silc_2022
), function(x) {
  year <- x$year[1]
  tmp <- x %>%
    recode_housing_cost_share()

  tmp %>%
    ggplot(., aes(x = r_housing_cost_share_income)) +
    geom_histogram(aes(y = ..density..)) +
    geom_vline(data = tmp %>% group_by(country) %>% summarise(mean_share = mean(r_housing_cost_share_income, na.rm = TRUE)),
               aes(xintercept = mean_share)) +
    facet_wrap(~country) +
    theme_minimal() +
    scale_x_continuous(labels = scales::label_percent(scale = 1)) +
    scale_y_continuous(labels = scales::label_percent()) +
    labs(x = "Share of disposable income spent on housing",
         y = "Share of households",
         title = year)

})
