tar_load(all_silc_households_precarity)

all_silc_households_precarity %>%
  filter(country %in% c("AT", "BE", "BG", "HR",
                        "CY", "CZ", "DK", "EE",
                        "FI", "FR", "DE", "EL",
                        "HU", "IE", "IT", "LV",
                        "LT", "LU", "MT", "NL",
                        "PL", "PT", "RO", "SK",
                        "SI", "ES", "SE", "UK")) %>%
  select(
    `Country` = country,
    `Year` = year,
    `0/4 dimensions of precariousness (%)` = dim_0,
    `1/4 dimensions of precariousness (%)` = dim_1,
    `2/4 dimensions of precariousness (%)` = dim_2,
    `3/4 dimensions of precariousness (%)` = dim_3,
    `4/4 dimensions of precariousness (%)` = dim_4,

    `0/3 dimensions of precariousness (%)` = dim3_0,
    `1/3 dimensions of precariousness (%)` = dim3_1,
    `2/3 dimensions of precariousness (%)` = dim3_2,
    `3/3 dimensions of precariousness (%)` = dim3_3,

    # `Housing overburden (%)` = mean_housing_overburden,
    #
    # `Housing insecurity (% precarious)` = mean_dim_insecurity,
    `Arrears on rent/mortgage (%)` = mean_arrears_mortgage_rent,
    `Arrears on utilities (%)` = mean_arrears_utility,

    # `Housing quality (% precarious, 2/2)` = mean_dim_quality,
    # `Housing quality (% precarious, 2/5)` = mean_dim_quality2,

    `Unable to keep dwelling warm (%)` = mean_ability_to_keep_warm,
    `Living in overcrowded dwelling (%)` = mean_overcrowded_eu,
    `Leaks/damp (%)` = mean_leaks_damp,
    `No toilet (%)` = mean_toilet,
    `No bath/shower (%)` = mean_bath_shower,

    # `Housing locality (% precarious)` = mean_dim_locality,
    `Crime, violence or vandalism in the area (%)` = mean_probs_crime,
    `Pollution, grime or other environmental problems (%)` = mean_probs_pollution,
    `Noise from neighbours or from the street (%)` = mean_probs_noise
  ) %>%
  pivot_longer(cols = 3:ncol(.), names_to = "variable", values_to = "value") %>%
  pivot_wider(names_from = Year, values_from = value) %>%
  openxlsx::write.xlsx(., "tabs/household_precarity2.xlsx",
                       na.string = "")
