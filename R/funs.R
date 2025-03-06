add_weights <- function(df, path){
  if(grepl("sav$", path)){
    weights <- read_sav(path) %>%
      select(DB020, DB030, hh_cross_weight = DB090)
  }else{
    weights <- read_dta(path) %>%
      select(DB020, DB030, hh_cross_weight = DB090)
  }

  df %>%
    left_join(., weights, by = c("HB030"="DB030", "HB020"="DB020"),
              relationship = "one-to-one")
}

load_r_file <- function(path){
  if(grepl("sav$", path)){
    tmp <- read_sav(path)
  }else{
    tmp <- read_dta(path)
  }

  if("RX010" %in% colnames(tmp) & !"RB082" %in% colnames(tmp)){
    tmp <- tmp %>%
      rename(age = RX010)
  }

  if("RB082" %in% colnames(tmp)){
    tmp <- tmp %>%
      rename(age = RB082)
  }

  tmp %>%
    mutate(
      person_id = RB030,
      hh_id = floor(RB030 / 100),
      has_partner = as.numeric(RB240_F == 1),
      partner_id = RB240,
      father_id = RB220,
      mother_id = RB230,
      partner_in_same_household = floor(partner_id / 100) == hh_id,
      couple = as.numeric(has_partner & partner_in_same_household)
    ) %>%
    select(person_id, hh_id, year = RB010, country = RB020,
           couple, birth_year = RB080, partner_id,
           has_partner, partner_in_same_household,
           father_id, mother_id,
           age,
           sex = RB090) %>%
    mutate(
      age = as.numeric(age),
      birth_year = as.numeric(birth_year)
    ) %>%
    mutate(
      age = if_else(is.na(age), year - birth_year, age)
    )
}

merge_register_df <- function(df1, r_df){
  full_join(df1, r_df, by = c("year", "country", "hh_id", "person_id"),
            relationship = "one-to-one")
}

select_and_rename_vars <- function(df, rename_lookup){
  out <- df %>%
    rename(
      any_of(rename_lookup)
    )

    out %>%
      select(-starts_with("H", ignore.case = FALSE)) %>%
      select(-starts_with("M", ignore.case = FALSE))
}

recode_education <- function(education){
  case_when(
      education == 0 ~ "Pre-primary",
      education == 1 | education == 100 ~ "Primary",
      education == 2 | education == 200 ~ "Lower secondary",
      education == 3 | between(education, 300, 399) ~ "Upper secondary",
      education == 4 | between(education, 400, 499) ~ "Post-secondary non-tertiary",
      education == 5 | between(education, 500, 599) ~ "First stage tertiary",
      education == 6 | education >= 600 ~ "Second stage tertiary"
  ) %>%
    factor(., levels = c("Pre-primary", "Primary",
                         "Lower secondary", "Upper secondary",
                         "Post-secondary non-tertiary",
                         "First stage tertiary",
                         "Second stage tertiary"))
}

recode_econ_status_2020 <- function(econ_status){
  case_when(
    econ_status %in% c(1:4) ~ "Employed",
    econ_status == 5 ~ "Unemployed",
    econ_status == 7 ~ "Retired",
    econ_status == 8 ~ "Unable to work due to health problems",
    econ_status == 6 ~ "Student",
    econ_status == 10 ~ "Fulfilling domestic tasks",
    econ_status %in% c(9, 11) ~ "Other"
  )
}

recode_econ_status_2021 <- function(econ_status){
  case_when(
    econ_status == 1 ~ "Employed",
    econ_status == 2 ~ "Unemployed",
    econ_status == 3 ~ "Retired",
    econ_status == 4 ~ "Unable to work due to health problems",
    econ_status == 5 ~ "Student",
    econ_status == 6 ~ "Fulfilling domestic tasks",
    econ_status %in% c(7, 8) ~ "Other"
  )
}

select_and_rename_personal <- function(df){
  out <- df %>%
    rename(
      year = PB010,
      country = PB020,
      person_id = PB030,
      # birth_year = PB140,
      # sex = PB150,
      # RB240_F
    ) %>%
    mutate(
      hh_id = as.character(person_id)
    ) %>%
    mutate(
      hh_id = as.numeric(substr(hh_id, 1, nchar(hh_id) - 2))
    )

  if("PC170" %in% colnames(out)){
    out <- out %>%
      rename(
        changed_dwelling = PC170,
        changed_dwelling_reason = PC180
      )
  }

  if("PE040" %in% colnames(out)){
    out <- out %>%
      rename(education = PE040)
  }

  if("PE041" %in% colnames(out)){
    out <- out %>%
      rename(education = PE041)
  }

  if("PL032" %in% colnames(out)){
    out <- out %>%
      mutate(econ_status = recode_econ_status_2021(PL032))
  }

  if("PL031" %in% colnames(out)){
    out <- out %>%
      mutate(econ_status = recode_econ_status_2020(PL031))
  }

  out %>%
    select(-starts_with("P", ignore.case = FALSE)) %>%
    mutate(r_education = recode_education(education))
}

merge_personal_df <- function(hh_df, p_df){
  full_join(hh_df, p_df, by = c("year", "country", "hh_id"),
            relationship = "one-to-many")
}

create_colnames_df <- function(df, year){
  tibble(
    variable = colnames(df),
    survey_year = year
  ) %>%
    mutate(value = 1) %>%
    tidyr::pivot_wider(., names_from = variable, values_from = value)
}

recode_arrears <- function(x){
  factor(x, levels = 1:3,
         labels = c("Yes, once",
                    "Yes, twice or more",
                    "No"))
}

calculate_required_rooms <- function(df){
  df %>%
    as_polars_df() %>%
    group_by(hh_id, country, year) %>%
    summarise(
      n_couple = sum(couple / 2),
      n_single_male_18plus = sum(age >= 18 & couple == 0 & sex == 1),
      n_single_female_18plus = sum(age >= 18 & couple == 0 & sex == 2),
      n_male_12_17 = sum(age >= 12 & age < 18 & sex == 1),
      n_female_12_17 = sum(age >= 12 & age < 18 & sex == 2),
      n_children_male = sum(age < 12 & sex == 1),
      n_children_female = sum(age < 12 & sex == 2),
      n_children = sum(age < 12),
      n_persons = n(),
      .groups = "drop"
    ) %>%
    mutate(
      required_rooms = 1 +
        n_couple +
        n_single_male_18plus +
        n_single_female_18plus +
        ceiling(n_male_12_17 / 2) +
        ceiling(n_female_12_17 / 2) +
        ceiling(n_children / 2)
    ) %>%
    as_tibble()
}

recode_vars <- function(df, r_rooms){
  full_join(df, r_rooms, by = c("hh_id", "country", "year")) %>%
    mutate(
      allowance_housing = if_else(allowance_housing < 0, 0, allowance_housing)
    ) %>%
    mutate(
      overcrowded_eurostat = as.numeric(required_rooms > rooms),
      overcrowded_simple = as.numeric(n_persons > rooms),
      income_share_on_housing = total_housing_cost /
        (income_disposable / 12) * 100,
      income_share_on_housing_wo_hb = total_housing_cost /
        ((income_disposable - allowance_housing) / 12) * 100,
      housing_overburden = as.numeric(income_share_on_housing > 40),
      housing_overburden_wo_hb = as.numeric(income_share_on_housing_wo_hb > 40),
    ) %>%
    mutate(
      flag_income_share_on_housing_out_of_range =
        income_share_on_housing < 0 | income_share_on_housing > 100,
      income_share_on_housing = case_when(
        income_share_on_housing < 0 ~ 0,
        income_share_on_housing > 100 ~ 100,
        TRUE ~ income_share_on_housing
      ),
      income_share_on_housing_wo_hb = case_when(
        income_share_on_housing_wo_hb < 0 ~ 0,
        income_share_on_housing_wo_hb > 100 ~ 100,
        TRUE ~ income_share_on_housing_wo_hb
      )
    )
}

label_vars <- function(df, cbook){
  vars <- intersect(colnames(df), unique(cbook$variable_name))
  purrr::walk(vars, function(x) {
    values <- cbook %>%
      filter(variable_name == x) %>%
      pull(value)

    labels <- cbook %>%
      filter(variable_name == x) %>%
      pull(label)

    df <<- df %>%
      mutate({{x}} := factor(.[[x]], levels = values, labels = labels))
  })

  df
}

summarise_precarity <- function(df){
  df %>%
    mutate(
      dim_affordability = housing_overburden,
      dim_insecurity = arrears_mortgage_rent %in% c("Yes, once", "Yes, twice or more") |
          arrears_utility %in% c("Yes, once", "Yes, twice or more"),
      dim_quality = case_when(
        is.na(overcrowded_eurostat) ~ NA,
        TRUE ~ (overcrowded_eurostat |
          ability_to_keep_warm == "No"),
      ),
      dim_quality2 = case_when(
        is.na(overcrowded_eurostat) ~ NA,
        TRUE ~ (overcrowded_eurostat |
                  ability_to_keep_warm == "No" |
                  bath_shower %in% c("No", "Yes, shared") |
                  toilet %in% c("No", "Yes, shared") |
                  leaks_damp == "Yes"),
      ),
      dim_locality =
        probs_noise == "Yes" |
          probs_crime == "Yes" |
          probs_noise == "Yes",
    ) %>%
    group_by(country, year) %>%
    summarise(
      # affordability
      mean_housing_overburden = wtd.mean(housing_overburden, w = hh_cross_weight) * 100,

      mean_housing_overburden_wo_hb = wtd.mean(housing_overburden_wo_hb, w = hh_cross_weight) * 100,
      # tenure security
      mean_arrears_mortgage_rent = wtd.mean(arrears_mortgage_rent %in% c("Yes, once", "Yes, twice or more"),
                                            w = hh_cross_weight) * 100,
      mean_arrears_utility = wtd.mean(arrears_utility %in% c("Yes, once", "Yes, twice or more"),
                                      w = hh_cross_weight) * 100,

      # quality
      mean_ability_to_keep_warm = wtd.mean(ability_to_keep_warm == "No", w = hh_cross_weight) * 100,
      mean_overcrowded_eu = wtd.mean(overcrowded_eurostat, w = hh_cross_weight) * 100,
      mean_overcrowded_si = wtd.mean(overcrowded_simple, w = hh_cross_weight) * 100,
      mean_leaks_damp = wtd.mean(leaks_damp == "Yes", w = hh_cross_weight) * 100,
      mean_bath_shower = wtd.mean(bath_shower %in% c("No", "Yes, shared"), w = hh_cross_weight) * 100,
      mean_toilet = wtd.mean(toilet %in% c("No", "Yes, shared"), w = hh_cross_weight) * 100,

      # locality
      mean_probs_crime = wtd.mean(probs_crime == "Yes", w = hh_cross_weight) * 100,
      mean_probs_pollution = wtd.mean(probs_pollution == "Yes", w = hh_cross_weight) * 100,
      mean_probs_noise = wtd.mean(probs_noise == "Yes", w = hh_cross_weight) * 100,

      # dimensions
      mean_dim_affordability = mean_housing_overburden,
      mean_dim_insecurity = wtd.mean(
        dim_insecurity,
        w = hh_cross_weight
      ) * 100,
      mean_dim_quality = wtd.mean(
        dim_quality,
        w = hh_cross_weight
      ) * 100,
      mean_dim_quality2 = wtd.mean(
        dim_quality2,
        w = hh_cross_weight
      ) * 100,
      mean_dim_locality = wtd.mean(
        dim_locality,
        w = hh_cross_weight
      ) * 100,
      dim_0 = wtd.mean(rowSums(across(c(dim_affordability, dim_insecurity, dim_quality,
                               dim_locality))) == 0,
                       w = hh_cross_weight) * 100,
      dim_1 = wtd.mean(rowSums(across(c(dim_affordability, dim_insecurity, dim_quality,
                                        dim_locality))) == 1,
                       w = hh_cross_weight) * 100,
      dim_2 = wtd.mean(rowSums(across(c(dim_affordability, dim_insecurity, dim_quality,
                                        dim_locality))) == 2,
                       w = hh_cross_weight) * 100,
      dim_3 = wtd.mean(rowSums(across(c(dim_affordability, dim_insecurity, dim_quality,
                                        dim_locality))) == 3,
                       w = hh_cross_weight) * 100,
      dim_4 = wtd.mean(rowSums(across(c(dim_affordability, dim_insecurity, dim_quality,
                                        dim_locality))) == 4,
                       w = hh_cross_weight) * 100,

      dim3_0 = wtd.mean(rowSums(across(c(dim_affordability, dim_insecurity, dim_quality2))) == 0,
                       w = hh_cross_weight) * 100,
      dim3_1 = wtd.mean(rowSums(across(c(dim_affordability, dim_insecurity, dim_quality2))) == 1,
                       w = hh_cross_weight) * 100,
      dim3_2 = wtd.mean(rowSums(across(c(dim_affordability, dim_insecurity, dim_quality2))) == 2,
                       w = hh_cross_weight) * 100,
      dim3_3 = wtd.mean(rowSums(across(c(dim_affordability, dim_insecurity, dim_quality2))) == 3,
                       w = hh_cross_weight) * 100,
      .groups = "drop"
    )

}

recode_takeup <- function(df){
  df %>%
    mutate(
      takeup_allowance_housing = allowance_housing > 0,
      takeup_allowance_family = allowance_family > 0,
      takeup_allowance_social = allowance_social > 0,
      takeup_any = takeup_allowance_housing | takeup_allowance_family |
        takeup_allowance_social
    )
}


add_income_quantiles <- function(tmp){
  tmp <- tmp %>%
    mutate(income_disposable_eqi = income_disposable / consumption_units)

  quantiles <- tmp %>%
    group_by(country) %>%
    summarise(
      p20 = wtd.quantile(income_disposable, hh_cross_weight, probs = c(0.2)),
      p40 = wtd.quantile(income_disposable, hh_cross_weight, probs = c(0.4)),
      p50 = wtd.quantile(income_disposable, hh_cross_weight, probs = c(0.5)),
      p60 = wtd.quantile(income_disposable, hh_cross_weight, probs = c(0.6)),
      p80 = wtd.quantile(income_disposable, hh_cross_weight, probs = c(0.8)),
      .groups = "drop"
    )

  quantiles_eqi <- tmp %>%
    group_by(country) %>%
    summarise(
      p20_eqi = wtd.quantile(income_disposable_eqi, hh_cross_weight, probs = c(0.2)),
      p40_eqi = wtd.quantile(income_disposable_eqi, hh_cross_weight, probs = c(0.4)),
      p50_eqi = wtd.quantile(income_disposable_eqi, hh_cross_weight, probs = c(0.5)),
      p60_eqi = wtd.quantile(income_disposable_eqi, hh_cross_weight, probs = c(0.6)),
      p80_eqi = wtd.quantile(income_disposable_eqi, hh_cross_weight, probs = c(0.8)),
      .groups = "drop"
    )

  tmp %>%
    left_join(., quantiles, by = "country") %>%
    left_join(., quantiles_eqi, by = "country") %>%
    mutate(
      income_disposable_quantile = case_when(
        income_disposable <= p20 ~ "1st quantile (lowest)",
        income_disposable <= p40 ~ "2nd quantile",
        income_disposable <= p60 ~ "3rd quantile",
        income_disposable <= p80 ~ "4th quantile",
        income_disposable > p80 ~ "5th quantile (highest)"
      ) %>% factor(., levels = c("1st quantile (lowest)",
                                 "2nd quantile",
                                 "3rd quantile",
                                 "4th quantile",
                                 "5th quantile (highest)")),
      income_disposable_median = if_else(
        income_disposable <= p50, "Under median", "Above median"
      ) %>% factor(., levels = c("Under median", "Above median")),
      income_disposable_eqi_quantile = case_when(
        income_disposable_eqi <= p20_eqi ~ "1st quantile (lowest)",
        income_disposable_eqi <= p40_eqi ~ "2nd quantile",
        income_disposable_eqi <= p60_eqi ~ "3rd quantile",
        income_disposable_eqi <= p80_eqi ~ "4th quantile",
        income_disposable_eqi > p80_eqi ~ "5th quantile (highest)"
      ) %>% factor(., levels = c("1st quantile (lowest)",
                                 "2nd quantile",
                                 "3rd quantile",
                                 "4th quantile",
                                 "5th quantile (highest)")),
      income_disposable_eqi_median = if_else(
        income_disposable_eqi <= p50_eqi, "Under median", "Above median"
      ) %>% factor(., levels = c("Under median", "Above median"))
    )

}

calculate_consumption_units <- function(r_df){
  cu <- r_df %>%
    mutate(age = (year - 1) - birth_year,
           above13 = age > 13,
           below13 = age <= 13) %>%
    group_by(country, hh_id) %>%
    summarise(
      n_above13 = sum(above13),
      n_below13 = sum(below13),
      n_members = n(),
      .groups = "drop"
    )

  cu %>%
    mutate(consumption_units = 1 + (n_above13 - 1) * 0.5 + n_below13 * 0.3)
}
