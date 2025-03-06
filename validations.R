library(dplyr)
library(targets)
library(validate)

tar_load(matches("r_silc_[0-9]{4}"))
tar_load(all_silc)

silc_validator <- validator(
  is_unique(hh_id, person_id, country),
  income_share_on_housing >= 0 & income_share_on_housing <= 100,
  !is.na(hh_cross_weight)
)

s2007 <- confront(r_silc_2007, silc_validator)
summary(s2007)
plot(s2007)

violating(r_silc_2007, s2007) %>% View()
