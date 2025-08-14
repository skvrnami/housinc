library(haven)

bhs <- read_sav("data/british_housing_survey/2022/spss/spss28/generalfs22_eul.sav") |> 
    as_factor() |> 
    select(
        hh_weight = aagfh22,
        region = govreg1, 
        tenure = tenure4x,
        id = serialanon
    )

int_bhs <- read_sav("data/british_housing_survey/2022/spss/spss28/interviewfs22_eul.sav") |> 
    mutate(
        AHCinceq = as.numeric(AHCinceq), 
        ALLincx = as.numeric(ALLincx),
        amthbenx = as.numeric(amthbenx),
        hhincx = as.numeric(hhincx)
    ) |> 
    as_factor() |> 
    rename(id = serialanon) |>
    left_join(bhs, by = "id") |>
    mutate(
        r_dwelling_type = fct_case_when(
            accomhh1 %in% c("detached house or bungalow") ~ "Detached house",
            accomhh1 %in% c("detached house or bungalow",
            "semi-detached", "terrace/end of terrace") ~ "Semi-detached or terraced house",
            accomhh1 %in% c("purpose built flat/maisonette") ~ "Appartment",
            TRUE ~ "Other"
        ),
        age = agehrp6x,
        hh_age = case_when(
        age == " 16 - 24" ~ "Below 25", 
        age == " 65 or over" ~ "Above 65", 
        TRUE ~ "26-64"
        ) |> factor(levels = c("26-64", "Below 25", "Above 65")), 
        income_disposable_eqi = BHCinceq, # weekly
        income_disposable_eqi_quantile = BHCinceqv5,
        # allowance_housing = ALLincx # annual
        allowance_housing = amthbenx * 4, # monthly
        overcrowded_eurostat = bedstdx %in% c(
            "two or more below standard", "one below standard"
        ),
        econ_status = emphrpx, 
        r_econ_status = case_when(
            econ_status %in% c("full-time work", "part-time work") ~ "Employed",
            econ_status %in% c("retired") ~ "Retired",
            TRUE ~ "Other"
        ) |> factor(levels = c("Employed", "Retired", "Other")), 
        hh_type = case_when(
            hhcompx %in% c("one person under 60", "one person aged 60 or over") ~ "Lone adult",
            hhcompx %in% c("couple, no dependent child(ren) under 60", "couple, no dependent child(ren) aged 60 or over") ~ "Adult household, no child", 
            hhcompx == "lone parent with dependent child(ren)" ~ "Lone parent with children", 
            hhcompx == "couple with dependent child(ren)" ~ "Adults with children", 
            TRUE ~ "Other"
        ),
        has_mortgage = !is.na(mortwkx),
        received_housing_benefit = !is.na(Housbenx),
        tenure_status = case_when(
            tenure == "owner occupied" & has_mortgage ~ "Owner with outstanding mortgage",
            tenure == "owner occupied" & !has_mortgage ~ "Owner without outstanding mortgage",
            tenure == "private rented" ~ "Tenant, rent at market price",
            tenure %in% c("local authority", "housing association") ~ "Tenant, rent at reduced price"
        ), 
        rent_month = rentwkx * 4,# weekly
        net_income_month = hhincx / 12, 
        net_income_month_wo_hb = net_income_month - allowance_housing,
        income_share_on_housing_wo_hb = rent_month /
            ((net_income_month - allowance_housing)) * 100,
        income_share_on_housing_eurostat = (rent_month - allowance_housing) / 
            ((net_income_month - allowance_housing)) * 100,
        housing_overburden = as.numeric(income_share_on_housing > 40),
        housing_overburden_wo_hb = as.numeric(income_share_on_housing_wo_hb > 40)
    )
