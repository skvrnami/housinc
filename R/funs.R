add_weights <- function(df, path){
  if(grepl("sav$", path)){
    weights <- read_sav(path) %>%
      select(DB020, DB030, region = DB040, urbanisation = DB100, hh_cross_weight = DB090)
  }else{
    weights <- read_dta(path) %>%
      select(DB020, DB030, region = DB040, urbanisation = DB100, hh_cross_weight = DB090)
  }

  df %>%
    left_join(., weights, by = c("HB030"="DB030", "HB020"="DB020"),
              relationship = "one-to-one")
}

add_long_weights <- function(df, path){
  weights <- readRDS(path) %>%
    select(DB010, DB020, DB030, region = DB040, urbanisation = DB100, hh_long_weight = DB095)

  df %>%
    left_join(., weights,
              by = c("HB010"="DB010", "HB020"="DB020",
                     "HB030"="DB030"),
              relationship = "one-to-one")
}

load_r_file <- function(path){
  if(grepl("sav$", path)){
    tmp <- read_sav(path)
  }else if(grepl("rds$", path)){
    tmp <- readRDS(path)
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

  if("RX040" %in% colnames(tmp)){
    tmp <- tmp %>%
      rename(
        work_intensity = RX040,
        low_work_intensity = RX050,
        severe_material_social_deprivation = RX060,
        at_risk_of_poverty_or_social_exclusion = RX070
      )
  }

  tmp %>%
    mutate(
      person_id = RB030,
      hh_id = RX030,
      has_partner = as.numeric(RB240_F == 1),
      partner_id = RB240,
      father_id = RB220,
      mother_id = RB230,
      indi_cross_weight = RB050,
      # partner_in_same_household = floor(partner_id / 100) == hh_id,
      couple = as.numeric(has_partner) # & partner_in_same_household)
    ) %>%
    select(person_id, hh_id, year = RB010, country = RB020,
           couple, birth_year = RB080, partner_id,
           has_partner, # partner_in_same_household,
           father_id, mother_id,
           age, indi_cross_weight,
           sex = RB090,
           any_of(c("work_intensity",
                    "low_work_intensity",
                    "severe_material_social_deprivation",
                    "at_risk_of_poverty_or_social_exclusion"))) %>%
    mutate(
      age = as.numeric(age),
      birth_year = as.numeric(birth_year)
    ) %>%
    mutate(
      age = if_else(is.na(age), year - birth_year, age)
    )
}

load_r_file_long <- function(path){
  if(grepl("sav$", path)){
    tmp <- read_sav(path)
  }else if(grepl("rds$", path)){
    tmp <- readRDS(path)
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
      hh_id = RB040,
      has_partner = as.numeric(RB240_F == 1),
      partner_id = RB240,
      father_id = RB220,
      mother_id = RB230,
      indi_weight_long_base = RB060,
      # partner_in_same_household = floor(partner_id / 100) == hh_id,
      couple = as.numeric(has_partner) # & partner_in_same_household)
    ) %>%
    select(person_id, hh_id, year = RB010, country = RB020,
           couple, birth_year = RB080, partner_id,
           has_partner, # partner_in_same_household,
           father_id, mother_id, indi_weight_long_base,
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
  if("HS011" %in% colnames(df)){
    df <- df %>%
    mutate(
      HS011 = if_else(HS011_F == -2, 3, as.numeric(HS011))
    )
  }

  if("HS021" %in% colnames(df)){
    df <- df %>%
      mutate(
        HS021 = if_else(HS021_F == -2, 3, as.numeric(HS021))
      )
  }

  if("HS031" %in% colnames(df)){
    df <- df %>%
      mutate(
        HS031 = if_else(HS031_F == -2, 3, as.numeric(HS031))
      )
  }

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
      hh_id = PX030,
      person_gross_cash_income = PY010G,
      person_net_cash_income = PY010N,
      person_gross_noncash_income = PY020G,
      person_net_noncash_income = PY020N,
      person_gross_selfemployed_income = PY050G,
      person_net_selfemployed_income = PY050N,
      person_private_pensions = PY080G,
      person_gross_unemployment_benefits = PY090G,
      person_net_unemployment_benefits = PY090N,
      person_gross_oldage_benefits = PY100G,
      person_gross_survivor_benefits = PY110G,
      person_gross_sickness_benefits = PY120G,
      person_gross_disability_benefits = PY130G,
      person_gross_education_benefits = PY140G,
      person_net_unemployment_benefits = PY090N,
      person_net_oldage_benefits = PY100N,
      person_net_survivor_benefits = PY110N,
      person_net_sickness_benefits = PY120N,
      person_net_disability_benefits = PY130N,
      person_net_education_benefits = PY140N
      # occupation_main = PL051A,
      # occupation_last = PL051B
    ) # %>%
    # mutate(
    #   hh_id = as.character(person_id)
    # ) %>%
    # mutate(
    #   hh_id = as.numeric(substr(hh_id, 1, nchar(hh_id) - 2))
    # )

  if("PL040A" %in% colnames(out)){
    out <- out %>%
      rename(
        status_in_employment_main = PL040A,
        status_in_employment_last = PL040B
      )
  }

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

  if("PD080" %in% colnames(out)){
    out <- out %>%
      rename(
        have_internet_connection = PD080,
        have_two_shoes = PD030,
        capacity_spend_money_on_yourself = PD070,
        capacity_replace_clothes = PD020,
        participate_leisure_activity = PD060,
        get_together_w_friends = PD050
      )
  }
  # if("PB040" %in% colnames(out)){
  #   out <- out %>%
  #     rename(indi_cross_weight = PB040)
  # }

  if("PB050" %in% colnames(out)){
    out <- out %>%
      rename(indi_long_weight_base = PB050)
  }

  if("PL145" %in% colnames(out)){
    out <- out %>%
      rename(full_part_time_job = PL145)
  }

  if("PL060" %in% colnames(out)){
    out <- out %>%
      rename(
        hours_in_main_job = PL060
      )
  }

  if("PL100" %in% colnames(out)){
    out <- out %>%
      rename(
        hours_other_jobs = PL100
      )
  }

  if("PL073" %in% colnames(out)){
    out <- out %>%
      rename(
        months_full_time_employee = PL073,
        months_part_time_employee = PL074,
        months_full_time_selfemployed = PL075,
        months_part_time_selfemployed = PL076,
        months_unemployed = PL085,
        months_ill = PL086,
        months_student = PL087,
        months_military = PL088,
        months_domestic_tasks = PL089,
        months_other = PL090
      )
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
      total_housing_cost = if_else(total_housing_cost < 0, 0, total_housing_cost),
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
        is.na(toilet) ~ NA,
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

      dim3_0 = wtd.mean(rowSums(across(c(dim_affordability, dim_insecurity, dim_quality))) == 0,
                       w = hh_cross_weight) * 100,
      dim3_1 = wtd.mean(rowSums(across(c(dim_affordability, dim_insecurity, dim_quality))) == 1,
                       w = hh_cross_weight) * 100,
      dim3_2 = wtd.mean(rowSums(across(c(dim_affordability, dim_insecurity, dim_quality))) == 2,
                       w = hh_cross_weight) * 100,
      dim3_3 = wtd.mean(rowSums(across(c(dim_affordability, dim_insecurity, dim_quality))) == 3,
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

add_income_quantiles_long <- function(tmp, weight_quantiles = TRUE){
  tmp <- tmp %>%
    mutate(income_disposable_eqi = income_disposable / consumption_units)

  if(weight_quantiles){
    quantiles <- tmp %>%
      group_by(country, year) %>%
      summarise(
        p20 = wtd.quantile(income_disposable, hh_long_weight, probs = c(0.2), na.rm = TRUE),
        p40 = wtd.quantile(income_disposable, hh_long_weight, probs = c(0.4), na.rm = TRUE),
        p50 = wtd.quantile(income_disposable, hh_long_weight, probs = c(0.5), na.rm = TRUE),
        p60 = wtd.quantile(income_disposable, hh_long_weight, probs = c(0.6), na.rm = TRUE),
        p80 = wtd.quantile(income_disposable, hh_long_weight, probs = c(0.8), na.rm = TRUE),
        .groups = "drop"
      )

    quantiles_eqi <- tmp %>%
      group_by(country, year) %>%
      summarise(
        p20_eqi = wtd.quantile(income_disposable_eqi, hh_long_weight, probs = c(0.2), na.rm = TRUE),
        p40_eqi = wtd.quantile(income_disposable_eqi, hh_long_weight, probs = c(0.4), na.rm = TRUE),
        p50_eqi = wtd.quantile(income_disposable_eqi, hh_long_weight, probs = c(0.5), na.rm = TRUE),
        p60_eqi = wtd.quantile(income_disposable_eqi, hh_long_weight, probs = c(0.6), na.rm = TRUE),
        p80_eqi = wtd.quantile(income_disposable_eqi, hh_long_weight, probs = c(0.8), na.rm = TRUE),
        .groups = "drop"
      )
  }else{
    quantiles <- tmp %>%
      group_by(country, year) %>%
      summarise(
        p20 = quantile(income_disposable, probs = c(0.2), na.rm = TRUE),
        p40 = quantile(income_disposable, probs = c(0.4), na.rm = TRUE),
        p50 = quantile(income_disposable, probs = c(0.5), na.rm = TRUE),
        p60 = quantile(income_disposable, probs = c(0.6), na.rm = TRUE),
        p80 = quantile(income_disposable, probs = c(0.8), na.rm = TRUE),
        .groups = "drop"
      )

    quantiles_eqi <- tmp %>%
      group_by(country, year) %>%
      summarise(
        p20_eqi = quantile(income_disposable_eqi, probs = c(0.2), na.rm = TRUE),
        p40_eqi = quantile(income_disposable_eqi, probs = c(0.4), na.rm = TRUE),
        p50_eqi = quantile(income_disposable_eqi, probs = c(0.5), na.rm = TRUE),
        p60_eqi = quantile(income_disposable_eqi, probs = c(0.6), na.rm = TRUE),
        p80_eqi = quantile(income_disposable_eqi, probs = c(0.8), na.rm = TRUE),
        .groups = "drop"
      )
  }

  tmp %>%
    left_join(., quantiles, by = c("country", "year")) %>%
    left_join(., quantiles_eqi, by = c("country", "year")) %>%
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

calculate_consumption_units_long <- function(r_df){
  cu <- r_df %>%
    mutate(age = (year - 1) - birth_year,
           above13 = age > 13,
           below13 = age <= 13) %>%
    group_by(country, hh_id, year) %>%
    summarise(
      n_above13 = sum(above13),
      n_below13 = sum(below13),
      n_members = n(),
      .groups = "drop"
    )

  cu %>%
    mutate(consumption_units = 1 + (n_above13 - 1) * 0.5 + n_below13 * 0.3)
}

calculate_sum_deprivation_items <- function(df){
  df %>%
    # mutate(
    #   across(c(capacity_to_face_expenses,
    #            capacity_to_afford_holiday,
    #            arrears_mortgage_rent,
    #            arrears_utility,
    #            arrears_other,
    #            capacity_to_afford_meat,
    #            ability_to_keep_warm,
    #            have_car,
    #            capacity_to_replace_furniture,
    #            have_internet_connection,
    #            capacity_replace_clothes,
    #            have_two_shoes,
    #            capacity_spend_money_on_yourself,
    #            get_together_w_friends,
    #            participate_leisure_activity),
    #          as_factor)
    # ) %>%
    mutate(
      deprived_capacity_to_face_expenses = as.numeric(capacity_to_face_expenses != "Yes"),
      deprived_capacity_to_afford_holiday = as.numeric(capacity_to_afford_holiday != "Yes"),
      deprived_capacity_arrears = as.numeric(
        arrears_mortgage_rent != "No" &
          arrears_utility != "No" &
          arrears_other != "No"
      ),
      deprived_capacity_to_afford_meat = as.numeric(capacity_to_afford_meat != "Yes"),
      deprived_ability_to_keep_warm = as.numeric(ability_to_keep_warm != "Yes"),
      # deprived_have_car = as.numeric(have_car != "Yes"),
      # deprived_capacity_to_replace_furniture = as.numeric(capacity_to_replace_furniture != "Yes"),
      # deprived_have_internet_connection = as.numeric(have_internet_connection != "Yes"),
      # deprived_capacity_replace_clothes = as.numeric(capacity_replace_clothes != "Yes"),
      # deprived_have_two_shoes = as.numeric(have_two_shoes != "Yes"),
      # deprived_capacity_spend_money_on_yourself = as.numeric(capacity_spend_money_on_yourself != "Yes"),
      # deprived_get_together_w_friends = as.numeric(get_together_w_friends != "Yes"),
      # deprived_participate_leisure_activity = as.numeric(participate_leisure_activity != "Yes"),

      deprived_have_car = as.numeric(have_car == "No - cannot afford"),
      deprived_capacity_to_replace_furniture = as.numeric(capacity_to_replace_furniture == "No - cannot afford"),
      deprived_have_internet_connection = as.numeric(have_internet_connection == "No - cannot afford it"),
      deprived_capacity_replace_clothes = as.numeric(capacity_replace_clothes == "No - cannot afford it"),
      deprived_have_two_shoes = as.numeric(have_two_shoes == "No - cannot afford it"),
      deprived_capacity_spend_money_on_yourself = as.numeric(capacity_spend_money_on_yourself == "No - cannot afford it"),
      deprived_get_together_w_friends = as.numeric(get_together_w_friends == "No - cannot afford it"),
      deprived_participate_leisure_activity = as.numeric(participate_leisure_activity == "No - cannot afford it"),

      sum_deprived_items = rowSums(across(starts_with("deprived"))),
      sum_deprived_items_wo_expenses = rowSums(across(c(
        deprived_capacity_to_afford_holiday, deprived_capacity_arrears, 
        deprived_capacity_to_afford_meat, deprived_ability_to_keep_warm, 
        deprived_have_car, deprived_capacity_to_replace_furniture,
        deprived_have_internet_connection, deprived_capacity_replace_clothes, 
        deprived_have_two_shoes, deprived_capacity_spend_money_on_yourself,
        deprived_get_together_w_friends, deprived_participate_leisure_activity
      )))
    )
}
