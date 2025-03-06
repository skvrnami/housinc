# Load packages required to define the pipeline:
library(crew)
library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("tibble", "haven", "dplyr", "Hmisc",
               "readxl", "tidyr", "ggplot2", "glue",
               "geofacet", "sf", "rnaturalearth",
               "cowplot", "rlang", "tidypolars",
               "validate"), # Packages that your targets need for their tasks.
  # controller = crew_controller_local(workers = 2),
  format = "qs" # Optionally set the default storage format. qs is fast.
)

tar_source()

# Replace the target list below with your own:
list(
  tar_target(
    codebook,
    read_excel("data/codebook.xlsx") %>%
      fill(., everything(), .direction = "down")
  ),

  tar_target(
    rename_lookup,
    c(
      year = "HB010",
      country = "HB020",
      hh_id = "HB030",
      month_interview = "HB050",
      year_interview = "HB060",
      dwelling_type = "HH010",
      rooms = "HH030",
      ability_to_keep_warm = "HH050",
      ability_to_make_ends = "HS120",
      capacity_to_face_expenses = "HS060",
      rent = "HH060",
      total_housing_cost = "HH070",
      fin_burden_debt = "HS150",
      income_gross = "HY010",
      income_disposable = "HY020",
      allowance_family = "HY050N",
      allowance_social = "HY060N",
      allowance_housing = "HY070N",
      tenure_status = "HH021",
      arrears_mortgage_rent = "HS011",
      arrears_utility = "HS021",
      arrears_other = "HS031",
      leaks_damp = "HH040",
      bath_shower = "HH081",
      toilet = "HH091",
      fin_burden_housing = "HS140",
      probs_too_dark = "HS160",
      probs_noise = "HS170",
      probs_pollution = "HS180",
      probs_crime = "HS190",
      reduced_utility_cost = "HS022",
      shortage_of_space = "HC010",
      immediate_risk_dwelling_change = "HC150",
      main_reasons_leaving_dwelling = "HC160",
      access_grocery = "HC090",
      access_banking = "HC100",
      access_postal = "HC110",
      access_transport = "HC120",
      access_healthcare = "HC130",
      ability_to_keep_cool = "HC070",
      heating_sytem = "HC001"
    )
  ),

  # SILC data ---------------------------------------------------------------
  tar_target(
    silc_2007, {
      year <- "2007"
      r_df <- load_r_file(glue("data/silc/{year}/SILC {year}_R.sav"))
      p_df <- read_sav(glue("data/silc/{year}/SILC {year}_P.sav")) %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav(glue("data/silc/{year}/SILC {year}_H.sav")) %>%
        add_weights(., glue("data/silc/{year}/SILC {year}_D.sav")) %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2007, {
      calculate_required_rooms(silc_2007)
    }
  ),

  tar_target(
    r_silc_2007, {
      recode_vars(silc_2007, r_rooms_2007) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2008, {
      year <- "2008"
      r_df <- load_r_file(glue("data/silc/{year}/SILC {year}_R.sav"))
      p_df <- read_sav(glue("data/silc/{year}/SILC {year}_P.sav")) %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav(glue("data/silc/{year}/SILC {year}_H.sav")) %>%
        add_weights(., glue("data/silc/{year}/SILC {year}_D.sav")) %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2008, {
      calculate_required_rooms(silc_2008)
    }
  ),

  tar_target(
    r_silc_2008, {
      recode_vars(silc_2008, r_rooms_2008) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2009, {
      year <- "2009"
      r_df <- load_r_file(glue("data/silc/{year}/SILC {year}_R.sav"))
      p_df <- read_sav(glue("data/silc/{year}/SILC {year}_P.sav")) %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav(glue("data/silc/{year}/SILC {year}_H.sav")) %>%
        add_weights(., glue("data/silc/{year}/SILC {year}_D.sav")) %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2009, {
      calculate_required_rooms(silc_2009)
    }
  ),

  tar_target(
    r_silc_2009, {
      recode_vars(silc_2009, r_rooms_2009) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2010, {
      year <- "2010"
      r_df <- load_r_file(glue("data/silc/{year}/SILC {year}_R.sav"))
      p_df <- read_sav(glue("data/silc/{year}/SILC {year}_P.sav")) %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav(glue("data/silc/{year}/SILC {year}_H.sav")) %>%
        add_weights(., glue("data/silc/{year}/SILC {year}_D.sav")) %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2010, {
      calculate_required_rooms(silc_2010)
    }
  ),

  tar_target(
    r_silc_2010, {
      recode_vars(silc_2010, r_rooms_2010) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2011, {
      year <- "2011"
      r_df <- load_r_file(glue("data/silc/{year}/SILC {year}_R.sav"))
      p_df <- read_sav(glue("data/silc/{year}/SILC {year}_P.sav")) %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav(glue("data/silc/{year}/SILC {year}_H.sav")) %>%
        add_weights(., glue("data/silc/{year}/SILC {year}_D.sav")) %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2011, {
      calculate_required_rooms(silc_2011)
    }
  ),

  tar_target(
    r_silc_2011, {
      recode_vars(silc_2011, r_rooms_2011) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2012, {
      r_df <- load_r_file("data/silc/2012/SILC 2012_R.sav")
      p_df <- read_sav("data/silc/2012/SILC 2012_P.sav") %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav("data/silc/2012/SILC 2012_H.sav") %>%
        add_weights(., "data/silc/2012/SILC 2012_D.sav") %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2012, {
      calculate_required_rooms(silc_2012)
    }
  ),

  tar_target(
    r_silc_2012, {
      recode_vars(silc_2012, r_rooms_2012) %>%
      label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2013, {
      r_df <- load_r_file("data/silc/2013/SILC 2013_R.sav")
      p_df <- read_sav("data/silc/2013/SILC 2013_P.sav") %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav("data/silc/2013/SILC 2013_H.sav") %>%
        add_weights(., "data/silc/2013/SILC 2013_D.sav") %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2013, {
      calculate_required_rooms(silc_2013)
    }
  ),

  tar_target(
    r_silc_2013, {
      recode_vars(silc_2013, r_rooms_2013) %>%
      label_vars(., codebook) %>%
      recode_takeup()
    }
  ),

  tar_target(
    silc_2014, {
      r_df <- load_r_file("data/silc/2014/SILC 2014_R.sav")
      p_df <- read_sav("data/silc/2014/SILC 2014_P.sav") %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav("data/silc/2014/SILC 2014_H.sav") %>%
        add_weights(., "data/silc/2014/SILC 2014_D.sav") %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2014, {
      calculate_required_rooms(silc_2014)
    }
  ),

  tar_target(
    r_silc_2014, {
      recode_vars(silc_2014, r_rooms_2014) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2015, {
      r_df <- load_r_file("data/silc/2015/SILC 2015_R.sav")
      p_df <- read_sav("data/silc/2015/SILC 2015_P.sav") %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav("data/silc/2015/SILC 2015_H.sav") %>%
        add_weights(., "data/silc/2015/SILC 2015_D.sav") %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2015, {
      calculate_required_rooms(silc_2015)
    }
  ),

  tar_target(
    r_silc_2015, {
      recode_vars(silc_2015, r_rooms_2015) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2016, {
      r_df <- load_r_file("data/silc/2016/SILC 2016_R.sav")
      p_df <- read_sav("data/silc/2016/SILC 2016_P.sav") %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav("data/silc/2016/SILC 2016_H.sav") %>%
        add_weights(., "data/silc/2016/SILC 2016_D.sav") %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2016, {
      calculate_required_rooms(silc_2016)
    }
  ),

  tar_target(
    r_silc_2016, {
      recode_vars(silc_2016, r_rooms_2016) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2017, {
      r_df <- load_r_file("data/silc/2017/SILC 2017_R.sav")
      p_df <- read_sav("data/silc/2017/SILC 2017_P.sav") %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav("data/silc/2017/SILC 2017_H.sav") %>%
        add_weights(., "data/silc/2017/SILC 2017_D.sav") %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2017, {
      calculate_required_rooms(silc_2017)
    }
  ),

  tar_target(
    r_silc_2017, {
      recode_vars(silc_2017, r_rooms_2017) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2018, {
      r_df <- load_r_file("data/silc/2018/SILC 2018_R.dta")
      p_df <- read_dta("data/silc/2018/SILC 2018_P.dta") %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_dta("data/silc/2018/SILC 2018_H.dta") %>%
        add_weights(., "data/silc/2018/SILC 2018_D.dta") %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2018, {
      calculate_required_rooms(silc_2018)
    }
  ),

  tar_target(
    r_silc_2018, {
      recode_vars(silc_2018, r_rooms_2018) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2019, {
      r_df <- load_r_file("data/silc/2019/SILC 2019_R.dta")
      p_df <- read_dta("data/silc/2019/SILC 2019_P.dta") %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav("data/silc/2019/SILC 2019_H.sav") %>%
        add_weights(., "data/silc/2019/SILC 2019_D.dta") %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2019, {
      calculate_required_rooms(silc_2019)
    }
  ),

  tar_target(
    r_silc_2019, {
      recode_vars(silc_2019, r_rooms_2019) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2020, {
      r_df <- load_r_file("data/silc/2020/SILC 2020_R.sav")
      p_df <- read_sav("data/silc/2020/SILC 2020_P.sav") %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav("data/silc/2020/SILC 2020_H.sav") %>%
        add_weights(., "data/silc/2020/SILC 2020_D.sav") %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2020, {
      calculate_required_rooms(silc_2020)
    }
  ),

  tar_target(
    r_silc_2020, {
      recode_vars(silc_2020, r_rooms_2020) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2021, {
      r_df <- load_r_file("data/silc/2021/SILC 2021_R.sav")
      p_df <- read_sav("data/silc/2021/SILC 2021_P.sav") %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav("data/silc/2021/SILC 2021_H.sav") %>%
        add_weights(., "data/silc/2021/SILC 2021_D.sav") %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2021, {
      calculate_required_rooms(silc_2021)
    }
  ),

  tar_target(
    r_silc_2021, {
      recode_vars(silc_2021, r_rooms_2021) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2022, {
      r_df <- load_r_file("data/silc/2022/SILC 2022_R.sav")
      p_df <- read_sav("data/silc/2022/SILC 2022_P.sav") %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav("data/silc/2022/SILC 2022_H.sav") %>%
        add_weights(., "data/silc/2022/SILC 2022_D.sav") %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(
    r_rooms_2022, {
      calculate_required_rooms(silc_2022)
    }
  ),

  tar_target(
    r_silc_2022, {
      recode_vars(silc_2022, r_rooms_2022) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_2023, {
      r_df <- load_r_file("data/silc/2023/SILC 2023_R.sav")
      p_df <- read_sav("data/silc/2023/SILC 2023_P.sav") %>%
        select_and_rename_personal()
      cu <- calculate_consumption_units(r_df)

      read_sav("data/silc/2023/SILC 2023_H.sav") %>%
        add_weights(., "data/silc/2023/SILC 2023_D.sav") %>%
        select_and_rename_vars(., rename_lookup) %>%
        left_join(., cu, by = c("country", "hh_id")) %>%
        add_income_quantiles() %>%
        merge_personal_df(., p_df) %>%
        merge_register_df(., r_df)
    }
  ),

  tar_target(r_rooms_2023, {
    calculate_required_rooms(silc_2023)
  }),

  tar_target(
    r_silc_2023, {
      recode_vars(silc_2023, r_rooms_2023) %>%
        label_vars(., codebook) %>%
        recode_takeup()
    }
  ),

  tar_target(
    silc_variable_availability, {
      bind_rows(
        create_colnames_df(silc_2007, 2007),
        create_colnames_df(silc_2008, 2008),
        create_colnames_df(silc_2009, 2009),
        create_colnames_df(silc_2010, 2010),
        create_colnames_df(silc_2011, 2011),
        create_colnames_df(silc_2012, 2012),
        create_colnames_df(silc_2013, 2013),
        create_colnames_df(silc_2014, 2014),
        create_colnames_df(silc_2015, 2015),
        create_colnames_df(silc_2016, 2016),
        create_colnames_df(silc_2017, 2017),
        create_colnames_df(silc_2018, 2018),
        create_colnames_df(silc_2019, 2019),
        create_colnames_df(silc_2020, 2020),
        create_colnames_df(silc_2021, 2021),
        create_colnames_df(silc_2022, 2022),
        create_colnames_df(silc_2023, 2023)
      )
    }
  ),

  ## Final data -------------------------------------------
  tar_target(
    silc_merged, {
      bind_rows(
        r_silc_2011,
        r_silc_2012,
        r_silc_2013,
        r_silc_2014,
        r_silc_2015,
        r_silc_2016,
        r_silc_2017,
        r_silc_2018,
        r_silc_2019,
        r_silc_2020,
        r_silc_2021,
        r_silc_2022,
        r_silc_2023
      )
    }
  ),

  tar_target(
    silc_merged_households, {
      silc_merged %>%
        # mutate(person_no = person_id - hh_id * 100)
        group_by(hh_id, country, year) %>%
        slice(1)
    }
  ),

  # Validations -------------------------------------------
  tar_target(
    rules, {
      validator(
        `Unique IDs` = is_unique(hh_id, person_id, country),
        `Weight is not missing` = !is.na(hh_cross_weight),
        `Share on housing within (0, 100)` = income_share_on_housing >= 0 & income_share_on_housing <= 100,
        # share on housing with benefits is lower than share on housing without benefits
        `Share w/ benefits <= Share w/o benefits` = income_share_on_housing <= income_share_on_housing_wo_hb,
        `N of hh members` = (n_above13 + n_below13) == n_members,
        `Econ_status` = !is.na(econ_status)
      )
    }
  ),

  tar_target(
    validation_silc_2007,
    confront(r_silc_2007, rules)
  ),

  tar_target(
    validation_silc_2008,
    confront(r_silc_2008, rules)
  ),

  tar_target(
    validation_silc_2009,
    confront(r_silc_2009, rules)
  ),

  tar_target(
    validation_silc_2010,
    confront(r_silc_2010, rules)
  ),

  tar_target(
    validation_silc_2011,
    confront(r_silc_2011, rules)
  ),

  tar_target(
    validation_silc_2012,
    confront(r_silc_2012, rules)
  ),

  tar_target(
    validation_silc_2013,
    confront(r_silc_2013, rules)
  ),

  tar_target(
    validation_silc_2014,
    confront(r_silc_2014, rules)
  ),

  tar_target(
    validation_silc_2015,
    confront(r_silc_2015, rules)
  ),

  tar_target(
    validation_silc_2016,
    confront(r_silc_2016, rules)
  ),

  tar_target(
    validation_silc_2017,
    confront(r_silc_2017, rules)
  ),

  tar_target(
    validation_silc_2018,
    confront(r_silc_2018, rules)
  ),

  tar_target(
    validation_silc_2019,
    confront(r_silc_2019, rules)
  ),

  tar_target(
    validation_silc_2020,
    confront(r_silc_2020, rules)
  ),

  tar_target(
    validation_silc_2021,
    confront(r_silc_2021, rules)
  ),

  tar_target(
    validation_silc_2022,
    confront(r_silc_2022, rules)
  ),

  tar_target(
    validation_silc_2023,
    confront(r_silc_2023, rules)
  ),

  tar_render(validations_rmd,
             "validations.Rmd"),

  # Summary -----------------------------------------------
  tar_target(
    all_silc, {
      bind_rows(
        r_silc_2011,
        r_silc_2012,
        r_silc_2013,
        r_silc_2014,
        r_silc_2015,
        r_silc_2016,
        r_silc_2017,
        r_silc_2018,
        r_silc_2019,
        r_silc_2020,
        r_silc_2021,
        r_silc_2022,
        r_silc_2023
      ) %>%
        summarise_precarity()
    }
  ),

  tar_target(
    all_silc_households, {
      bind_rows(
        # r_silc_2007,
        # r_silc_2008,
        # r_silc_2009,
        # r_silc_2010,
        # r_silc_2011,
        r_silc_2012,
        r_silc_2013,
        r_silc_2014,
        r_silc_2015,
        r_silc_2016,
        r_silc_2017,
        r_silc_2018,
        r_silc_2019,
        r_silc_2020,
        r_silc_2021,
        r_silc_2022,
        r_silc_2023
      ) %>%
        group_by(hh_id, country, year) %>%
        slice(1) %>%
        ungroup %>%
        summarise_precarity()
  }),

  tar_target(
    all_silc_households_tenants, {
      bind_rows(
        # r_silc_2007,
        # r_silc_2008,
        # r_silc_2009,
        # r_silc_2010,
        # r_silc_2011,
        r_silc_2012,
        r_silc_2013,
        r_silc_2014,
        r_silc_2015,
        r_silc_2016,
        r_silc_2017,
        r_silc_2018,
        r_silc_2019,
        r_silc_2020,
        r_silc_2021,
        r_silc_2022,
        r_silc_2023
      ) %>%
        filter(grepl("Tenant", tenure_status)) %>%
        group_by(hh_id, country, year) %>%
        slice(1) %>%
        ungroup %>%
        summarise_precarity()
    }),

  tar_target(
    all_silc_households_owners, {
      bind_rows(
        # r_silc_2007,
        # r_silc_2008,
        # r_silc_2009,
        # r_silc_2010,
        # r_silc_2011,
        r_silc_2012,
        r_silc_2013,
        r_silc_2014,
        r_silc_2015,
        r_silc_2016,
        r_silc_2017,
        r_silc_2018,
        r_silc_2019,
        r_silc_2020,
        r_silc_2021,
        r_silc_2022,
        r_silc_2023
      ) %>%
        filter(grepl("Owner", tenure_status)) %>%
        group_by(hh_id, country, year) %>%
        slice(1) %>%
        ungroup %>%
        summarise_precarity()
    }),

  # Tables ------------------------------------------------
  tar_target(
    precarity_export, {
      all_silc_households %>%
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

          `Housing overburden (%)` = mean_housing_overburden,

          `Housing insecurity (% precarious)` = mean_dim_insecurity,
          `Arrears on rent/mortgage (%)` = mean_arrears_mortgage_rent,
          `Arrears on utilities (%)` = mean_arrears_utility,

          `Housing quality (% precarious, 2/2)` = mean_dim_quality,
          `Housing quality (% precarious, 2/5)` = mean_dim_quality2,

          `Unable to keep dwelling warm (%)` = mean_ability_to_keep_warm,
          `Living in overcrowded dwelling (%)` = mean_overcrowded_eu,
          `Leaks/damp (%)` = mean_leaks_damp,
          `No toilet (%)` = mean_toilet,
          `No bath/shower (%)` = mean_bath_shower,

          `Housing locality (% precarious)` = mean_dim_locality,
          `Crime, violence or vandalism in the area (%)` = mean_probs_crime,
          `Pollution, grime or other environmental problems (%)` = mean_probs_pollution,
          `Noise from neighbours or from the street (%)` = mean_probs_noise
        ) %>%
        writexl::write_xlsx(., "tabs/household_precariousness.xlsx")
    }
  ),

  # Charts ------------------------------------------------
  tar_target(
    silc_countries_grid,
    europe_countries_grid1 %>%
      as_tibble() %>%
      mutate(
        code = case_when(
          name == "United Kingdom" ~ "UK",
          name == "Greece" ~ "EL",
          TRUE ~ code
        )
      ) %>%
      filter(code %in% all_silc_households$country) %>%
      as.data.frame()
  ),

  ## Time trends ---------------------------
  ### Affordability --------------------------------
  tar_target(
    chart_affordability,
    ggplot(all_silc_households, aes(x = year, y = mean_dim_affordability)) +
      geom_line() +
      geom_point(size = 0.7) +
      theme_minimal() +
      facet_geo(~country, grid = silc_countries_grid, label = "name") +
      labs(title = "Housing affordability",
           subtitle = "Share of households paying more than 40% of its income on housing costs",
           x = "", y = "") +
      scale_y_continuous(labels = scales::label_percent(scale = 1)) +
      theme(legend.position = "none")
  ),

  tar_target(
    chart_affordability_file,
    ggsave("figs/time_affordability.png", chart_affordability,
           width = 10, height = 9, bg = "white")
  ),

  ### Insecurity --------------------------------
  tar_target(
    chart_insecurity,
    all_silc_households %>%
      filter(year >= 2008) %>%
      ggplot(., aes(x = year, y = mean_dim_insecurity)) +
      geom_line() +
      geom_point(size = 0.7) +
      theme_minimal() +
      facet_geo(~country, grid = silc_countries_grid, label = "name") +
      labs(title = "Housing insecurity",
           subtitle = "Share of households with arrears on rent, mortgage or utilities",
           x = "", y = "") +
      scale_y_continuous(labels = scales::label_percent(scale = 1)) +
      theme(legend.position = "none")
  ),

  tar_target(
    chart_insecurity_file,
    ggsave("figs/time_insecurity.png", chart_insecurity,
           width = 10, height = 9, bg = "white")
  ),

  tar_target(
    chart_insecurity_arrears_rent,
    all_silc_households %>%
      filter(year >= 2008) %>%
      ggplot(., aes(x = year, y = mean_arrears_mortgage_rent)) +
      geom_line() +
      geom_point(size = 0.7) +
      theme_minimal() +
      facet_geo(~country, grid = silc_countries_grid, label = "name") +
      labs(title = "Housing insecurity",
           subtitle = "Share of households with arrears on rent or mortgage",
           x = "", y = "") +
      scale_y_continuous(labels = scales::label_percent(scale = 1)) +
      theme(legend.position = "none")
  ),

  tar_target(
    chart_insecurity_arrears_rent_file,
    ggsave("figs/time_insecurity_arrears_rent.png",
           chart_insecurity_arrears_rent,
           width = 10, height = 9, bg = "white")
  ),

  tar_target(
    chart_insecurity_arrears_utility,
    all_silc_households %>%
      filter(year >= 2008) %>%
      ggplot(., aes(x = year, y = mean_arrears_utility)) +
      geom_line() +
      geom_point(size = 0.7) +
      theme_minimal() +
      facet_geo(~country, grid = silc_countries_grid, label = "name") +
      labs(title = "Housing insecurity",
           subtitle = "Share of households with arrears on utilities",
           x = "", y = "") +
      scale_y_continuous(labels = scales::label_percent(scale = 1)) +
      theme(legend.position = "none")
  ),

  tar_target(
    chart_insecurity_arrears_utility_file,
    ggsave("figs/time_insecurity_arrears_utilities.png",
           chart_insecurity_arrears_utility,
           width = 10, height = 9, bg = "white")
  ),

  ### Quality --------------------------------
  tar_target(
    chart_quality,
    all_silc_households %>%
    ggplot(., aes(x = year, y = mean_dim_quality)) +
      geom_line() +
      geom_point(size = 0.7) +
      theme_minimal() +
      facet_geo(~country, grid = silc_countries_grid, label = "name") +
      labs(title = "Housing quality",
           subtitle = "Share of households with poor housing quality (overcrowding or unable to keep warm)",
           x = "", y = "") +
      scale_y_continuous(labels = scales::label_percent(scale = 1)) +
      theme(legend.position = "none")
  ),

  tar_target(
    chart_quality_file,
    ggsave("figs/time_quality.png",
           chart_quality,
           width = 10, height = 9, bg = "white")
  ),

  tar_target(
    chart_quality_overcrowding,
    all_silc_households %>%
      ggplot(., aes(x = year, y = mean_overcrowded_eu)) +
      geom_line() +
      geom_point(size = 0.7) +
      theme_minimal() +
      facet_geo(~country, grid = silc_countries_grid, label = "name") +
      labs(title = "Housing quality",
           subtitle = "Share of households living in overcrowded dwelling",
           x = "", y = "") +
      scale_y_continuous(labels = scales::label_percent(scale = 1)) +
      theme(legend.position = "none")
  ),

  tar_target(
    chart_quality_overcrowding_file,
    ggsave("figs/time_quality_overcrowding.png",
           chart_quality_overcrowding,
           width = 10, height = 9, bg = "white")
  ),

  tar_target(
    chart_quality_warm,
    all_silc_households %>%
      ggplot(., aes(x = year, y = mean_ability_to_keep_warm)) +
      geom_line() +
      geom_point(size = 0.7) +
      theme_minimal() +
      facet_geo(~country, grid = silc_countries_grid, label = "name") +
      labs(title = "Housing quality",
           subtitle = "Share of households unable to keep dwelling warm",
           x = "", y = "") +
      scale_y_continuous(labels = scales::label_percent(scale = 1)) +
      theme(legend.position = "none")
  ),

  tar_target(
    chart_quality_warm_file,
    ggsave("figs/time_quality_warm.png",
           chart_quality_warm,
           width = 10, height = 9, bg = "white")
  ),

  ### Locality --------------------------------
  tar_target(
    chart_locality,
    all_silc_households %>%
      filter(!is.na(mean_dim_locality)) %>%
      ggplot(., aes(x = year, y = mean_dim_locality)) +
      geom_line() +
      geom_point(size = 0.7) +
      theme_minimal() +
      facet_geo(~country, grid = silc_countries_grid, label = "name") +
      labs(title = "Neighbourhood quality",
           subtitle = "Share of households with poor neighbourhood quality (pollution, noise or criminality)",
           x = "", y = "") +
      scale_y_continuous(labels = scales::label_percent(scale = 1)) +
      theme(legend.position = "none")
  ),

  tar_target(
    chart_locality_file,
    ggsave("figs/time_locality.png",
           chart_locality,
           width = 10, height = 9, bg = "white")
  ),

  tar_target(
    chart_locality_crime,
    all_silc_households %>%
      filter(!is.na(mean_probs_crime)) %>%
      ggplot(., aes(x = year, y = mean_probs_crime)) +
      geom_line() +
      geom_point(size = 0.7) +
      theme_minimal() +
      facet_geo(~country, grid = silc_countries_grid, label = "name") +
      labs(title = "Problems with crime in neighbourhood",
           subtitle = "Share of households with problems with crime",
           x = "", y = "") +
      scale_y_continuous(labels = scales::label_percent(scale = 1)) +
      theme(legend.position = "none")
  ),

  tar_target(
    chart_locality_crime_file,
    ggsave("figs/time_locality_crime.png",
           chart_locality_crime,
           width = 10, height = 9, bg = "white")
  ),

  tar_target(
    chart_locality_noise,
    all_silc_households %>%
      filter(!is.na(mean_probs_noise)) %>%
      ggplot(., aes(x = year, y = mean_probs_noise)) +
      geom_line() +
      geom_point(size = 0.7) +
      theme_minimal() +
      facet_geo(~country, grid = silc_countries_grid, label = "name") +
      labs(title = "Problems with noise",
           subtitle = "Share of households with problems with noise",
           x = "", y = "") +
      scale_y_continuous(labels = scales::label_percent(scale = 1)) +
      theme(legend.position = "none")
  ),

  tar_target(
    chart_locality_noise_file,
    ggsave("figs/time_locality_noise.png",
           chart_locality_noise,
           width = 10, height = 9, bg = "white")
  ),

  tar_target(
    chart_locality_pollution,
    all_silc_households %>%
      filter(!is.na(mean_probs_pollution)) %>%
      ggplot(., aes(x = year, y = mean_probs_pollution)) +
      geom_line() +
      geom_point(size = 0.7) +
      theme_minimal() +
      facet_geo(~country, grid = silc_countries_grid, label = "name") +
      labs(title = "Problems with pollution",
           subtitle = "Share of households with problems with pollution",
           x = "", y = "") +
      scale_y_continuous(labels = scales::label_percent(scale = 1)) +
      theme(legend.position = "none")
  ),

  tar_target(
    chart_locality_pollution_file,
    ggsave("figs/time_locality_pollution.png",
           chart_locality_pollution,
           width = 10, height = 9, bg = "white")
  ),

  ## Dimensions -------------------------------------------
  tar_target(
    chart_dimensions, {
      all_silc_households %>%
        pivot_longer(., cols = matches("dim_[0-9]"),
                     names_to = "dim_precarity",
                     values_to = "pct") %>%
        mutate(dim_precarity = gsub("dim_", "", dim_precarity)) %>%
        ggplot(., aes(x = year, y = pct, fill = dim_precarity)) +
        geom_bar(stat = "identity") +
        scale_y_continuous(labels = scales::label_percent(scale = 1)) +
        facet_wrap(vars(country)) +
        theme_minimal() +
        scale_fill_viridis_d() +
        labs(x = "Year", y = "% of households",
             fill = "Housing precarity dimensions") +
        theme(legend.position = "top")
    }
  ),

  tar_target(
    chart_dimensions_file,
    ggsave("figs/precarity_dimensions.png", chart_dimensions,
           bg = "white", width = 10, height = 7)
  ),

  tar_target(
    chart_dimensions2, {
      all_silc_households %>%
        pivot_longer(., cols = matches("dim3_[0-9]"),
                     names_to = "dim_precarity",
                     values_to = "pct") %>%
        mutate(dim_precarity = gsub("dim3_", "", dim_precarity)) %>%
        ggplot(., aes(x = year, y = pct, fill = dim_precarity)) +
        geom_bar(stat = "identity") +
        scale_y_continuous(labels = scales::label_percent(scale = 1)) +
        scale_fill_viridis_d() +
        facet_wrap(vars(country)) +
        theme_minimal() +
        labs(x = "Year", y = "% of households",
             fill = "Housing precarity dimensions") +
        theme(legend.position = "top")
    }
  ),

  tar_target(
    chart_dimensions2_file,
    ggsave("figs/precarity_dimensions3.png", chart_dimensions2,
           bg = "white", width = 10, height = 7)
  ),

  ### Tenants only -------------------------
  tar_target(
    chart_insecurity_arrears_rent_tenants,
    all_silc_households_tenants %>%
      filter(year >= 2008) %>%
      ggplot(., aes(x = year, y = mean_arrears_mortgage_rent)) +
      geom_line() +
      geom_point(size = 0.7) +
      theme_minimal() +
      facet_geo(~country, grid = silc_countries_grid, label = "name") +
      labs(title = "Housing insecurity among tenants",
           subtitle = "Share of households with arrears on rent or mortgage",
           x = "", y = "") +
      scale_y_continuous(labels = scales::label_percent(scale = 1)) +
      theme(legend.position = "none")
  ),

  tar_target(
    chart_insecurity_arrears_rent_tenants_file,
    ggsave("figs/time_insecurity_arrears_rent_tenants.png",
           chart_insecurity_arrears_rent,
           width = 10, height = 9, bg = "white")
  ),

  tar_target(
    chart_insecurity_arrears_utility_tenants,
    all_silc_households_tenants %>%
      filter(year >= 2008) %>%
      ggplot(., aes(x = year, y = mean_arrears_utility)) +
      geom_line() +
      geom_point(size = 0.7) +
      theme_minimal() +
      facet_geo(~country, grid = silc_countries_grid, label = "name") +
      labs(title = "Housing insecurity among tenants",
           subtitle = "Share of households with arrears on utilities",
           x = "", y = "") +
      scale_y_continuous(labels = scales::label_percent(scale = 1)) +
      theme(legend.position = "none")
  ),

  tar_target(
    chart_insecurity_arrears_utility_tenants_file,
    ggsave("figs/time_insecurity_arrears_utilities_tenants.png",
           chart_insecurity_arrears_utility_tenants,
           width = 10, height = 9, bg = "white")
  ),

  ## Core countries ----------------------
  # UK, Finland, Germany, Netherlands / Romania, Italy, Belgium, Czechia, and Estonia
  tar_target(
    chart_dimensions_core, {
        all_silc_households %>%
          mutate(country = as.character(country)) %>%
          filter(country %in% c("UK", "FI", "DE", "NL",
                                "RO", "IT", "BE", "CZ",
                                "EE")) %>%
          pivot_longer(., cols = matches("dim3_[0-9]"),
                       names_to = "dim_precarity",
                       values_to = "pct") %>%
          mutate(dim_precarity = gsub("dim3_", "", dim_precarity)) %>%
          ggplot(., aes(x = year, y = pct, fill = dim_precarity)) +
          geom_bar(stat = "identity") +
          scale_y_continuous(labels = scales::label_percent(scale = 1)) +
          facet_wrap(vars(country)) +
          theme_minimal() +
          scale_fill_viridis_d() +
          labs(x = "Year", y = "% of households",
               fill = "Housing precarity dimensions") +
          theme(legend.position = "top")
    }
  ),

  tar_target(
    chart_dimensions_core_2023, {
      dimensions_data <- all_silc_households %>%
        mutate(country = as.character(country)) %>%
        filter(country %in% c("UK", "FI", "DE", "NL",
                              "RO", "IT", "BE", "CZ",
                              "EE")) %>%
        filter(year == 2023) %>%
        pivot_longer(., cols = matches("dim3_[0-9]"),
                     names_to = "dim_precarity",
                     values_to = "pct") %>%
        mutate(dim_precarity = gsub("dim3_", "", dim_precarity),
               country = case_when(
                 country == "UK" ~ "United Kingdom",
                 country == "FI" ~ "Finland",
                 country == "DE" ~ "Germany",
                 country == "NL" ~ "Netherlands",
                 country == "RO" ~ "Romania",
                 country == "IT" ~ "Italy",
                 country == "BE" ~ "Belgium",
                 country == "CZ" ~ "Czechia",
                 country == "EE" ~ "Estonia"
               ))

      countries <- dimensions_data %>%
        filter(dim_precarity == "0") %>%
        arrange(desc(pct)) %>%
        pull(country)

      dimensions_data %>%
        mutate(dim_precarity = factor(dim_precarity, levels = as.character(3:0)),
               country = factor(country, levels = countries)) %>%
        ggplot(., aes(x = country, y = pct, fill = dim_precarity)) +
        geom_bar(stat = "identity") +
        scale_y_continuous(labels = scales::label_percent(scale = 1)) +
        coord_flip() +
        theme_minimal() +
        scale_fill_viridis_d(direction = -1) +
        labs(x = "", y = "Share of households",
             fill = "Housing precarity dimensions",
             caption = "Data: EU-SILC 2023") +
        theme(legend.position = "top") +
        guides(fill = guide_legend(reverse = TRUE))
    }
  ),

  tar_target(
    chart_dimensions_core_2023_file,
    ggsave("figs/report/core_dimensions.png",
           chart_dimensions_core_2023,
           width = 8, height = 6, bg = "white")
  ),

  tar_target(
    core_countries, {
      all_silc_households %>%
        mutate(country = as.character(country)) %>%
        filter(country %in% c("UK", "FI", "DE", "NL",
                              "RO", "IT", "BE", "CZ",
                              "EE")) %>%
        filter(year == 2023) %>%
        mutate(
          country = case_when(
            country == "UK" ~ "United Kingdom",
            country == "FI" ~ "Finland",
            country == "DE" ~ "Germany",
            country == "NL" ~ "Netherlands",
            country == "RO" ~ "Romania",
            country == "IT" ~ "Italy",
            country == "BE" ~ "Belgium",
            country == "CZ" ~ "Czechia",
            country == "EE" ~ "Estonia"
          )
        )
    }
  ),

  tar_target(
    chart_core_affordability, {
      countries_order <- core_countries %>%
        arrange(mean_housing_overburden) %>%
        pull(country)

      core_countries %>%
        ggplot(., aes(x = factor(country, levels = countries_order),
                      y = mean_housing_overburden)) +
        geom_bar(stat = "identity", fill = "#440154FF") +
        scale_y_continuous(labels = scales::label_percent(scale = 1)) +
        coord_flip() +
        theme_minimal() +
        # scale_fill_viridis_d(direction = -1) +
        labs(x = "", y = "Share of households",
             title = "Housing affordability",
             subtitle = "Housing overburden (over 40% of disposable income spent on housing)",
             # fill = "Housing precarity dimensions",
             caption = "Data: EU-SILC 2023")
    }
  ),

  tar_target(
    chart_core_affordability_file,
    ggsave("figs/report/core_affordability.png",
           chart_core_affordability, width = 6, height = 5,
           bg = "white")
  ),

  tar_target(
    chart_core_insecurity_single, {
      countries_order <- core_countries %>%
        arrange(mean_dim_insecurity) %>%
        pull(country)

      core_countries %>%
        ggplot(., aes(x = factor(country, levels = countries_order),
                      y = mean_dim_insecurity)) +
        geom_bar(stat = "identity", fill = "#440154FF") +
        scale_y_continuous(labels = scales::label_percent(scale = 1)) +
        coord_flip() +
        theme_minimal() +
        # scale_fill_viridis_d(direction = -1) +
        labs(x = "", y = "Share of households",
             title = "Housing insecurity",
             # fill = "Housing precarity dimensions",
             caption = "Data: EU-SILC 2023")
    }
  ),

  tar_target(
    chart_core_insecurity_single_file,
    ggsave("figs/report/core_insecurity_single.png",
           chart_core_insecurity_single, width = 7, height = 5,
           bg = "white")
  ),

  tar_target(
    chart_core_insecurity, {
      countries_order <- core_countries %>%
        arrange(mean_dim_insecurity) %>%
        pull(country)

      core_countries %>%
        select(country, year, contains("arrears")) %>%
        pivot_longer(., cols = contains("arrears"),
                     names_to = "arrears", values_to = "pct") %>%
        mutate(arrears = if_else(
          arrears == "mean_arrears_mortgage_rent",
          "Arrears on mortgage/rent",
          "Arrears on utilities"
        ) %>% factor(., levels = c("Arrears on utilities",
                                   "Arrears on mortgage/rent"))) %>%
        ggplot(., aes(x = factor(country, levels = countries_order), y = pct)) +
        geom_bar(stat = "identity", fill = "#440154FF") +
        scale_y_continuous(labels = scales::label_percent(scale = 1)) +
        coord_flip() +
        theme_minimal() +
        facet_grid(~arrears) +
        # scale_fill_viridis_d(direction = -1) +
        labs(x = "", y = "Share of households",
             title = "Housing insecurity",
             # fill = "Housing precarity dimensions",
             caption = "Data: EU-SILC 2023")
    }
  ),

  tar_target(
    chart_core_insecurity_file,
    ggsave("figs/report/core_insecurity.png",
           chart_core_insecurity, width = 8, height = 5,
           bg = "white")
  ),

  tar_target(
    chart_core_quality_single, {
      countries_order <- core_countries %>%
        arrange(mean_dim_quality2) %>%
        pull(country)

      core_countries %>%
        ggplot(., aes(x = factor(country, levels = countries_order),
                      y = mean_dim_quality2)) +
        geom_bar(stat = "identity", fill = "#440154FF") +
        scale_y_continuous(labels = scales::label_percent(scale = 1)) +
        coord_flip() +
        theme_minimal() +
        # scale_fill_viridis_d(direction = -1) +
        labs(x = "", y = "Share of households",
             title = "Housing quality",
             # fill = "Housing precarity dimensions",
             caption = "Data: EU-SILC 2023")
    }
  ),

  tar_target(
    chart_core_quality_single_file,
    ggsave("figs/report/core_quality_single.png",
           chart_core_quality_single, width = 8, height = 5,
           bg = "white")
  ),

  tar_target(
    chart_core_quality, {
      countries_order <- core_countries %>%
        arrange(mean_dim_quality2) %>%
        pull(country)

      core_countries %>%
        select(country, year, mean_overcrowded_eu, mean_ability_to_keep_warm,
                mean_leaks_damp) %>%
        pivot_longer(., cols = c(mean_overcrowded_eu, mean_ability_to_keep_warm,
                                 mean_leaks_damp),
                     names_to = "problem", values_to = "pct") %>%
        mutate(problem = case_when(
          problem == "mean_overcrowded_eu" ~ "Overcrowding",
          problem == "mean_ability_to_keep_warm" ~ "Unable to keep dwelling warm",
          problem == "mean_leaks_damp" ~ "Leaks/damp",
          # problem == "mean_bath_shower" ~ "Without own bath/shower",
          # problem == "mean_toilet" ~ "Without own toilet"
        ) %>% factor(., levels = c("Overcrowding", "Leaks/damp", "Unable to keep dwelling warm")
        # "Without own bath/shower",
        # "Without own toilet"))) %>%
        )) %>%
        ggplot(., aes(x = factor(country, levels = countries_order), y = pct)) +
        geom_bar(stat = "identity", fill = "#440154FF") +
        scale_y_continuous(labels = scales::label_percent(scale = 1)) +
        coord_flip() +
        theme_minimal() +
        facet_grid(~problem) +
        # scale_fill_viridis_d(direction = -1) +
        labs(x = "", y = "Share of households",
             title = "Housing quality",
             # fill = "Housing precarity dimensions",
             caption = "Data: EU-SILC 2023")
    }
  ),

  tar_target(
    chart_core_quality_file,
    ggsave("figs/report/core_quality.png",
           chart_core_quality, width = 8, height = 5,
           bg = "white")
  ),

  ## Arrears -----------------------------
#   tar_target(
#     arrears_rent, {
#       bind_rows(
#         # r_silc_2007,
#         # r_silc_2008,
#         # r_silc_2009,
#         # r_silc_2010,
#         # r_silc_2011,
#         r_silc_2012,
#         r_silc_2013,
#         r_silc_2014,
#         r_silc_2015,
#         r_silc_2016,
#         r_silc_2017,
#         r_silc_2018,
#         r_silc_2019,
#         r_silc_2020,
#         r_silc_2021,
#         r_silc_2022,
#         r_silc_2023
#       ) %>%
#         filter(grepl("Tenant", tenure_status)) %>%
#         group_by(hh_id, country, year) %>%
#         slice(1) %>%
#         ungroup %>%
#         group_by(year, country, arrears_mortgage_rent) %>%
#         summarise(n = sum(hh_cross_weight)) %>%
#         filter(!is.na(arrears_mortgage_rent)) %>%
#         group_by(year, country) %>%
#         mutate(pct = n / sum(n) * 100) %>%
#         ggplot(., aes(x = year, y = pct, fill = arrears_mortgage_rent)) +
#         geom_bar(stat = "identity") +
#         scale_fill_viridis_d() +
#         theme_minimal() +
#         facet_geo(~country, grid = silc_countries_grid, label = "name") +
#         labs(title = "Arrears on rent, tenants only",
#              subtitle = "In the past twelve months, has the household been in arrears, i.e. has been unable to pay on time due to
# financial difficulties for rent?",
#              x = "", y = "", fill = "",
#              caption = "Data: EU-SILC (2012-2023)"
#         ) +
#         scale_y_continuous(labels = scales::label_percent(scale = 1)) +
#         theme(legend.position = "top",
#               panel.grid.minor = element_blank())
#     }
#   ),
#
#   tar_target(
#     arrears_rent_file,
#     ggsave("figs/tenants_arrears_rent.png", arrears_rent,
#            width = 11, height = 10, bg = "white")
#   ),
#
#   tar_target(
#     arrears_rent_without_no, {
#       bind_rows(
#         # r_silc_2007,
#         # r_silc_2008,
#         # r_silc_2009,
#         # r_silc_2010,
#         # r_silc_2011,
#         r_silc_2012,
#         r_silc_2013,
#         r_silc_2014,
#         r_silc_2015,
#         r_silc_2016,
#         r_silc_2017,
#         r_silc_2018,
#         r_silc_2019,
#         r_silc_2020,
#         r_silc_2021,
#         r_silc_2022,
#         r_silc_2023
#       ) %>%
#         filter(grepl("Tenant", tenure_status)) %>%
#         group_by(hh_id, country, year) %>%
#         slice(1) %>%
#         ungroup %>%
#         group_by(year, country, arrears_mortgage_rent) %>%
#         summarise(n = sum(hh_cross_weight)) %>%
#         filter(!is.na(arrears_mortgage_rent)) %>%
#         group_by(year, country) %>%
#         mutate(pct = n / sum(n) * 100) %>%
#         ungroup %>%
#         filter(arrears_mortgage_rent != "No") %>%
#         ggplot(., aes(x = year, y = pct, fill = arrears_mortgage_rent)) +
#         geom_bar(stat = "identity") +
#         scale_fill_viridis_d() +
#         theme_minimal() +
#         facet_geo(~country, grid = silc_countries_grid, label = "name") +
#         labs(title = "Arrears on rent, tenants only",
#              subtitle = "In the past twelve months, has the household been in arrears, i.e. has been unable to pay on time due to
#   financial difficulties for rent?",
#   x = "", y = "", fill = "") +
#         scale_y_continuous(labels = scales::label_percent(scale = 1)) +
#         theme(legend.position = "top")
#     }
#   ),
#
#   tar_target(
#     arrears_cartogram_en, {
#       arrears_2023_df <- r_silc_2023 %>%
#         filter(grepl("Tenant", tenure_status)) %>%
#         group_by(hh_id, country, year) %>%
#         slice(1) %>%
#         ungroup %>%
#         group_by(year, country, arrears_mortgage_rent) %>%
#         summarise(n = sum(hh_cross_weight)) %>%
#         filter(!is.na(arrears_mortgage_rent)) %>%
#         mutate(arrears_mortgage_rent = factor(arrears_mortgage_rent,
#                                               levels = c("Yes, twice or more",
#                                                          "Yes, once", "No"))) %>%
#         group_by(year, country) %>%
#         mutate(pct = n / sum(n) * 100) %>%
#         mutate(country = as.character(country))
#
#       head(arrears_2023_df)
#       unique_countries <- unique(arrears_2023_df$country)
#       pie_charts <- purrr::map_df(1:length(unique_countries), function(x) {
#         p <- arrears_2023_df %>%
#           filter(country == unique_countries[x]) %>%
#           ggplot() +
#           geom_col(aes(x = 1, y = pct, fill = arrears_mortgage_rent), width = 1) +
#           scale_fill_viridis_d() +
#           coord_polar(theta = "y") +
#           theme_void() +
#           theme(plot.margin = unit(c(0, 0, 0, 0),"cm"),
#                 legend.position = "none")
#
#         p_grob <- ggplotGrob(p)
#
#         tibble(
#           country = unique_countries[x],
#           pie_chart = list(p_grob)
#         )
#       })
#       #
#       # pie_charts
#       # world_map <- ne_countries(scale = 50, returnclass = 'sf')
#       # europe_map <- world_map %>%
#       #   # filter(featurecla == "Admin-0 country") %>%
#       #   filter(iso_a2_eh %in% c(arrears_2023$country, "UK", "GB", "CH",
#       #                           "RS", "BA", "GR", "BH", "UA", "MD", "MK",
#       #                           "ME", "AL", "XK")) %>%
#       #   left_join(., pie_charts, by = c("iso_a2_eh"="country")) %>%
#       #   select(iso_a2_eh, pie_chart)
#       #
#       # europe_map2 <- europe_map %>%
#       #   mutate(country_centroid_lon =
#       #            st_coordinates(st_centroid(., of_largest_polygon = TRUE)$geometry)[, 1],
#       #          country_centroid_lat =
#       #            st_coordinates(st_centroid(., of_largest_polygon = TRUE)$geometry)[, 2],
#       #          circle_area = as.numeric(st_area(.)),
#       #          circle_radius = as.numeric(sqrt(circle_area/pi) / 110000))
#       #
#       # p_base_map <- ggplot() +
#       #   geom_sf(data = europe_map2, fill = "gray80", color = alpha("black", 0.5)) +
#       #   # geom_sf(data = cartogram_dorling, fill = alpha("#dfc27d", 0.8), color = alpha("#a6611a", 0.8)) +
#       #   theme_void() +
#       #   scale_x_continuous(limits = c(-10, 35)) +
#       #   scale_y_continuous(limits = c(35, 65))
#       #
#       # valid_pie_charts <- europe_map2 %>%
#       #   mutate(
#       #     pie_is_null = purrr::map_lgl(pie_chart, is.null)
#       #   ) %>%
#       #   filter(!pie_is_null) %>%
#       #   mutate(
#       #     country_centroid_lon = case_when(
#       #       iso_a2_eh == "NO" ~ country_centroid_lon - 3,
#       #       iso_a2_eh == "DE" ~ country_centroid_lon - 0.6,
#       #       TRUE ~ country_centroid_lon
#       #     ),
#       #     country_centroid_lat = case_when(
#       #       iso_a2_eh == "NO" ~ country_centroid_lat - 2.8,
#       #       iso_a2_eh == "FI" ~ country_centroid_lat - 1.5,
#       #       iso_a2_eh == "SE" ~ country_centroid_lat - 1.5,
#       #       TRUE ~ country_centroid_lat
#       #     )
#       #   )
#       #
#       # legend <- get_legend(
#       #   arrears_2023 %>%
#       #     filter(country == "AT") %>%
#       #     ggplot() +
#       #     geom_col(aes(x = 1, y = pct, fill = arrears_mortgage_rent), width = 1) +
#       #     scale_fill_viridis_d() +
#       #     coord_polar(theta = "y") +
#       #     theme_void() +
#       #     labs(fill = "")
#       # )
#       #
#       # purrr::reduce(1:nrow(valid_pie_charts),
#       #               .f = function(x, y){
#       #                 x + annotation_custom(grob = valid_pie_charts$pie_chart[[y]],
#       #                                       xmin = valid_pie_charts$country_centroid_lon[y] - valid_pie_charts$circle_radius[y],
#       #                                       xmax = valid_pie_charts$country_centroid_lon[y] + valid_pie_charts$circle_radius[y],
#       #                                       ymin = valid_pie_charts$country_centroid_lat[y] - valid_pie_charts$circle_radius[y],
#       #                                       ymax = valid_pie_charts$country_centroid_lat[y] + valid_pie_charts$circle_radius[y])},
#       #               .init = p_base_map) +
#       #   annotation_custom(grob = legend,
#       #                     xmin = -8,
#       #                     xmax = -8,
#       #                     ymin = 65,
#       #                     ymax = 65) +
#       #   labs(caption = "Data: EU-SILC 2023",
#       #        title = "Arrears on rent among tenants",
#       #        subtitle = "In the past twelve months, has the household been in arrears,\ni.e. has been unable to pay on time due to financial difficulties for rent?") +
#       #   theme(plot.title.position = "plot")
#
#     }
#   ),
  #
  # tar_target(
  #   arrears_cartogram_en_file,
  #   ggsave("figs/arrears_en_cartogram.png", arrears_cartogram_en,
  #          width = 10, height = 10,
  #          bg = "white")
  # ),


  NULL

)
