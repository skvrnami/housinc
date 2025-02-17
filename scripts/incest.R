tar_load(r_silc_2018)

incest <- r_silc_2018 %>%
  filter(n_couple == 1.5) %>%
  select(hh_id, person_id, partner_id, age, sex, everything()) %>%
  filter(hh_id == 370500)

library(ggraph)
library(tidygraph)

edges1 <- incest %>%
  select(from = person_id,
         to = partner_id) %>%
  filter(!is.na(to)) %>%
  mutate(from = factor(from, levels = c(37050001, 37050002,
                                        37050003, 37050004)),
         to = factor(to, levels = c(37050001, 37050002,
                                    37050003, 37050004)),
         type = "partner")

edges2 <- incest %>%
  select(from = person_id,
         to = mother_id) %>%
  filter(!is.na(to)) %>%
  mutate(from = factor(from, levels = c(37050001, 37050002,
                                        37050003, 37050004)),
         to = factor(to, levels = c(37050001, 37050002,
                                    37050003, 37050004)),
         type = "parent")

nodes1 <- incest %>%
  select(person_id, age, sex) %>%
  mutate(person_id = factor(person_id, levels = c(37050001, 37050002,
                                                  37050003, 37050004))) %>%
  mutate(sex = factor(sex, levels = c(1, 2), labels = c("male", "female")),
         age = paste0(age, " years old"))

edges <- bind_rows(edges1, edges2)

tbl_graph(nodes = nodes1, edges = edges, node_key = "person_id") %>%
  ggraph() +
  geom_edge_arc(aes(colour = type),
                arrow = arrow(length = unit(4, 'mm')),
                start_cap = circle(3, 'mm'),
                end_cap = circle(3, 'mm')) +
  geom_node_point(aes(colour = sex), size = 3) +
  geom_node_text(aes(label = age), repel = TRUE) +
  theme_void() +
  theme(legend.position = "top")

ggsave("figs/other/incest.png", width = 7, height = 7,
       bg = "white")


