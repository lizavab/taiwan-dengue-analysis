library(sf)
library(data.table)
library(dplyr)
library(ggplot2)
library(RColorBrewer)

# Prepare data 
map <- read_sf("taiwan.shp")
map <- map %>% mutate(TOWNCODE = as.integer(TOWNCODE)) 
data <- fread("data_2011_2024.csv", header = T)
data <- data[data$year > 2011,] # Remove year 2011 (only needed for lag calculation)

# Dengue case count (DCC) heatmap
cases_heatmap <- 
  data %>% 
  group_by(year, month) %>%
  summarise(cases = sum(case_count)) %>% 
  ggplot(aes(x = month, y = year, fill = cases)) + 
  geom_raster() +
  ylab("") + 
  xlab("") +
  scale_fill_gradientn(name = "log(DCC)", colours = brewer.pal(9, "Reds"), 
                       trans = "log1p", 
                       breaks = c(0, 10, 100, 1000), 
                       labels = c(0, 10, 100, 1000)) + 
  scale_x_continuous(breaks = c(1:12), 
                     labels = c("Jan", "Feb", "Mar", "Apr", 
                                "May", "Jun", "Jul", "Aug", 
                                "Sep", "Oct", "Nov", "Dec")) +
  scale_y_continuous(breaks = 2012:2024) + 
  theme_classic() +
  # Fontsizes
  theme(
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.key.size = unit(1, "cm")
  )

ggsave("cases_heatmap.png", height = 20, width = 23, units = "cm")

# Dengue incidence rate (DIR) heatmap
dir_heatmap <- 
  data %>% 
  group_by(year, month) %>%
  summarise(cases = sum(case_count),
            pop = sum(total_pop)) %>% 
  # Calculate DIR (per 100,000 population)
  mutate(var = cases / pop * 10^5) %>% 
  ggplot(aes(x = month, y = year, fill = var)) + 
  geom_raster() +
  ylab("") + 
  xlab("") +
  scale_fill_gradientn(name = "log(DIR)", colours = brewer.pal(9, "Reds"), 
                       trans = "log1p", 
                       breaks = c(0, 1, 5, 20), 
                       labels = c(0, 1, 5, 20)) + 
  scale_x_continuous(breaks = c(1:12), 
                     labels = c("Jan", "Feb", "Mar", "Apr", 
                                "May", "Jun", "Jul", "Aug", 
                                "Sep", "Oct", "Nov", "Dec")) +
  scale_y_continuous(breaks = 2012:2024) + 
  theme_classic() +
  theme(
    axis.text.x = element_text(size = 12),
    axis.text.y = element_text(size = 12),
    legend.title = element_text(size = 14),
    legend.text = element_text(size = 12),
    legend.key.size = unit(1, "cm")
  )

ggsave("dir_heatmap.png", height = 20, width = 23, units = "cm")

# Annual dengue incidence rate (DIR) by township
dir_annual <- 
  data %>% 
  group_by(year, code) %>%
  # Calculate annual DIR (per 100,000 population)
  summarise(cases = sum(case_count),
            pop = sum(total_pop)) %>% 
  mutate(var = cases / pop * 10^5)  %>%
  # Add townships
  left_join(map, ., by = c("TOWNCODE" = "code")) %>% 
  ggplot() + 
  geom_sf(aes(fill = var), lwd = 0, color = NA) +
  scale_fill_gradientn(name = "log(DIR)", colours = brewer.pal(9, "Reds"), 
                       trans = "log1p", breaks = c(0, 10, 100), 
                       labels = c(0, 10, 100) ) + 
  theme_void() +
  facet_wrap(~year, ncol = 5)

ggsave("dir_annual.pdf", height = 20, width = 30, units = "cm")
