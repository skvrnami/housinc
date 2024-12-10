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

select_and_rename_vars <- function(df){
  out <- df %>%
    rename(
      year = HB010,
      country = HB020,
      hh_id = HB030,
      month_interview = HB050,
      year_interview = HB060,
      dwelling_type = HH010,
      tenure_status = HH021,
      rooms = HH030,
      ability_to_keep_warm = HH050,
      ability_to_make_ends = HS120,
      capacity_to_face_expenses = HS060,
      rent = HH060,
      total_housing_cost = HH070,
      arrears_mortgage_rent = HS011,
      arrears_utility = HS021,
      arrears_other = HS031,
      fin_burden_debt = HS150,
      income_gross = HY010,
      income_disposable = HY020,
      allowance_family = HY050N,
      allowance_social = HY060N,
      allowance_housing = HY070N
    )

    if("HH040" %in% colnames(out)){
      out <- out %>%
        rename(
          leaks_damp = HH040,
          bath_shower = HH081,
          toilet = HH091,
          fin_burden_housing = HS140,
          probs_too_dark = HS160,
          probs_noise = HS170,
          probs_pollution = HS180,
          probs_crime = HS190
        )
    }

    if("HS022" %in% colnames(out)){
      out <- out %>%
        rename(
          reduced_utility_cost = HS022
        )
    }

    if("HC010" %in% colnames(out) & out$year[1] != 2020){
      out <- out %>%
        rename(
          shortage_of_space = HC010
        )
    }

    if("HC150" %in% colnames(out)){
      out <- out %>%
        rename(
          immediate_risk_dwelling_change = HC150,
          main_reasons_leaving_dwelling = HC160,
          access_grocery = HC090,
          access_banking = HC100,
          access_postal = HC110,
          access_transport = HC120,
          access_healthcare = HC130
        )
    }

    if("HC070" %in% colnames(out)){
      out <- out %>%
        rename(
          ability_to_keep_cool = HC070
        )
    }

    if("HC001" %in% colnames(out)){
      out <- out %>%
        rename(
          heating_sytem = HC001
        )
    }

    out %>%
      select(-starts_with("H", ignore.case = FALSE))
}

select_and_rename_personal <- function(df){
  out <- df %>%
    rename(
      year = PB010,
      country = PB020,
      person_id = PB030,
      birth_year = PB140,
      sex = PB150
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

  out %>%
    select(-starts_with("P", ignore.case = FALSE))
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
