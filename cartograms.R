library(sf)
library(ggplot2)
library(targets)
library(rnaturalearth)
library(extrafont)

extrafont::font_import(pattern = "Inter", prompt = FALSE)

tar_load(r_silc_2023)

# English chart
arrears_2023 <- r_silc_2023 %>%
  filter(grepl("Tenant", tenure_status)) %>%
  group_by(hh_id, country, year) %>%
  slice(1) %>%
  ungroup %>%
  group_by(year, country, arrears_mortgage_rent) %>%
  summarise(n = sum(hh_cross_weight)) %>%
  filter(!is.na(arrears_mortgage_rent)) %>%
  mutate(arrears_mortgage_rent = factor(arrears_mortgage_rent,
                                        levels = c("Yes, twice or more",
                                                   "Yes, once", "No"))) %>%
  group_by(year, country) %>%
  mutate(pct = n / sum(n) * 100)

pie_charts <- purrr::map_df(unique(arrears_2023$country), function(country) {
  p <- arrears_2023 %>%
    filter(country == !!country) %>%
    ggplot() +
    geom_col(aes(x = 1, y = pct, fill = arrears_mortgage_rent), width = 1) +
    scale_fill_viridis_d() +
    coord_polar(theta = "y") +
    theme_void() +
    theme(plot.margin = unit(c(0, 0, 0, 0),"cm"),
          legend.position = "none")

  p_grob <- ggplotGrob(p)

  tibble(
    country = country,
    pie_chart = list(p_grob)
  )
})

world_map <- ne_countries(scale = 50, returnclass = 'sf')
europe_map <- world_map %>%
  # filter(featurecla == "Admin-0 country") %>%
  filter(iso_a2_eh %in% c(arrears_2023$country, "UK", "GB", "CH",
                          "RS", "BA", "GR", "BH", "UA", "MD", "MK",
                          "ME", "AL", "XK")) %>%
  left_join(., pie_charts, by = c("iso_a2_eh"="country")) %>%
  select(iso_a2_eh, pie_chart)

europe_map2 <- europe_map %>%
  mutate(country_centroid_lon =
           st_coordinates(st_centroid(., of_largest_polygon = TRUE)$geometry)[, 1],
         country_centroid_lat =
           st_coordinates(st_centroid(., of_largest_polygon = TRUE)$geometry)[, 2],
         circle_area = as.numeric(st_area(.)),
         circle_radius = as.numeric(sqrt(circle_area/pi) / 110000))

p_base_map <- ggplot() +
  geom_sf(data = europe_map2, fill = "gray80", color = alpha("black", 0.5)) +
  # geom_sf(data = cartogram_dorling, fill = alpha("#dfc27d", 0.8), color = alpha("#a6611a", 0.8)) +
  theme_void() +
  scale_x_continuous(limits = c(-10, 35)) +
  scale_y_continuous(limits = c(35, 65))

valid_pie_charts <- europe_map2 %>%
  mutate(
    pie_is_null = purrr::map_lgl(pie_chart, is.null)
  ) %>%
  filter(!pie_is_null) %>%
  mutate(
    country_centroid_lon = case_when(
      iso_a2_eh == "NO" ~ country_centroid_lon - 3,
      iso_a2_eh == "DE" ~ country_centroid_lon - 0.6,
      TRUE ~ country_centroid_lon
    ),
    country_centroid_lat = case_when(
      iso_a2_eh == "NO" ~ country_centroid_lat - 2.8,
      iso_a2_eh == "FI" ~ country_centroid_lat - 1.5,
      iso_a2_eh == "SE" ~ country_centroid_lat - 1.5,
      TRUE ~ country_centroid_lat
    )
  )

legend <- get_legend(
  arrears_2023 %>%
    filter(country == "AT") %>%
    ggplot() +
    geom_col(aes(x = 1, y = pct, fill = arrears_mortgage_rent), width = 1) +
    scale_fill_viridis_d() +
    coord_polar(theta = "y") +
    theme_void() +
    labs(fill = "")
)

purrr::reduce(1:nrow(valid_pie_charts),
       .f = function(x, y){
         x + annotation_custom(grob = valid_pie_charts$pie_chart[[y]],
                               xmin = valid_pie_charts$country_centroid_lon[y] - valid_pie_charts$circle_radius[y],
                               xmax = valid_pie_charts$country_centroid_lon[y] + valid_pie_charts$circle_radius[y],
                               ymin = valid_pie_charts$country_centroid_lat[y] - valid_pie_charts$circle_radius[y],
                               ymax = valid_pie_charts$country_centroid_lat[y] + valid_pie_charts$circle_radius[y])},
       .init = p_base_map) +
  annotation_custom(grob = legend,
                    xmin = -8,
                    xmax = -8,
                    ymin = 65,
                    ymax = 65) +
  labs(caption = "Data: EU-SILC 2023",
       title = "Arrears on rent among tenants",
       subtitle = "In the past twelve months, has the household been in arrears,\ni.e. has been unable to pay on time due to financial difficulties for rent?") +
  theme(plot.title.position = "plot")

ggsave("figs/cartogram_tenants_en.png", width = 10, height = 10,
       bg = "white")

# Czech chart
arrears_2023 <- r_silc_2023 %>%
  filter(grepl("Tenant", tenure_status)) %>%
  group_by(hh_id, country, year) %>%
  slice(1) %>%
  ungroup %>%
  group_by(year, country, arrears_mortgage_rent) %>%
  summarise(n = sum(hh_cross_weight)) %>%
  filter(!is.na(arrears_mortgage_rent)) %>%
  mutate(arrears_mortgage_rent = factor(arrears_mortgage_rent,
                                        levels = c("Yes, twice or more",
                                                   "Yes, once", "No"),
                                        labels = c("Ano, dvakrát a více",
                                                   "Ano, jednou", "Ne"))) %>%
  group_by(year, country) %>%
  mutate(pct = n / sum(n) * 100)

pie_charts <- purrr::map_df(unique(arrears_2023$country), function(country) {
  p <- arrears_2023 %>%
    filter(country == !!country) %>%
    ggplot() +
    geom_col(aes(x = 1, y = pct, fill = arrears_mortgage_rent), width = 1) +
    scale_fill_viridis_d() +
    coord_polar(theta = "y") +
    theme_void() +
    theme(plot.margin = unit(c(0, 0, 0, 0),"cm"),
          legend.position = "none")

  p_grob <- ggplotGrob(p)

  tibble(
    country = country,
    pie_chart = list(p_grob)
  )
})

world_map <- ne_countries(scale = 50, returnclass = 'sf')
europe_map <- world_map %>%
  # filter(featurecla == "Admin-0 country") %>%
  filter(iso_a2_eh %in% c(arrears_2023$country, "UK", "GB", "CH",
                          "RS", "BA", "GR", "BH", "UA", "MD", "MK",
                          "ME", "AL", "XK")) %>%
  left_join(., pie_charts, by = c("iso_a2_eh"="country")) %>%
  select(iso_a2_eh, pie_chart)

europe_map2 <- europe_map %>%
  mutate(country_centroid_lon =
           st_coordinates(st_centroid(., of_largest_polygon = TRUE)$geometry)[, 1],
         country_centroid_lat =
           st_coordinates(st_centroid(., of_largest_polygon = TRUE)$geometry)[, 2],
         circle_area = as.numeric(st_area(.)),
         circle_radius = as.numeric(sqrt(circle_area/pi) / 110000))

p_base_map <- ggplot() +
  geom_sf(data = europe_map2, fill = "gray80", color = alpha("black", 0.5)) +
  # geom_sf(data = cartogram_dorling, fill = alpha("#dfc27d", 0.8), color = alpha("#a6611a", 0.8)) +
  theme_void() +
  scale_x_continuous(limits = c(-10, 35)) +
  scale_y_continuous(limits = c(35, 65))

valid_pie_charts <- europe_map2 %>%
  mutate(
    pie_is_null = purrr::map_lgl(pie_chart, is.null)
  ) %>%
  filter(!pie_is_null) %>%
  mutate(
    country_centroid_lon = case_when(
      iso_a2_eh == "NO" ~ country_centroid_lon - 3,
      iso_a2_eh == "DE" ~ country_centroid_lon - 0.6,
      TRUE ~ country_centroid_lon
    ),
    country_centroid_lat = case_when(
      iso_a2_eh == "NO" ~ country_centroid_lat - 2.8,
      iso_a2_eh == "FI" ~ country_centroid_lat - 1.5,
      iso_a2_eh == "SE" ~ country_centroid_lat - 1.5,
      TRUE ~ country_centroid_lat
    )
  )

legend <- get_legend(
  arrears_2023 %>%
    filter(country == "AT") %>%
    ggplot() +
    geom_col(aes(x = 1, y = pct, fill = arrears_mortgage_rent), width = 1) +
    scale_fill_viridis_d() +
    coord_polar(theta = "y") +
    theme_void() +
    labs(fill = "") +
    theme(legend.text = element_text(family = "Inter", face = "italic"))

)

purrr::reduce(1:nrow(valid_pie_charts),
              .f = function(x, y){
                x + annotation_custom(grob = valid_pie_charts$pie_chart[[y]],
                                      xmin = valid_pie_charts$country_centroid_lon[y] - valid_pie_charts$circle_radius[y],
                                      xmax = valid_pie_charts$country_centroid_lon[y] + valid_pie_charts$circle_radius[y],
                                      ymin = valid_pie_charts$country_centroid_lat[y] - valid_pie_charts$circle_radius[y],
                                      ymax = valid_pie_charts$country_centroid_lat[y] + valid_pie_charts$circle_radius[y])},
              .init = p_base_map) +
  annotation_custom(grob = legend,
                    xmin = -11,
                    xmax = -11,
                    ymin = 65,
                    ymax = 65) +
  labs(caption = "Data: EU-SILC 2023",
       title = "Prodlení v placení nájmu",
       subtitle = "Dostala se Vaše domácnost někdy během posledních 12 měsíců do takových finančních problémů,\nže nebyla schopna zaplatit v termínu nájem?") +
  theme(plot.title.position = "plot",
        plot.title = element_text(family = "Inter", face = "bold"),
        plot.subtitle = element_text(family = "Inter", face = "italic"))

ggsave("figs/cartogram_tenants_cz.png", width = 10, height = 10,
       bg = "white")

