##################################################
# Clean California Finance Data
# Author: Joe Ornstein
# Version: 1.0
# Date: June 6, 2020
# ################################################

library(tidyverse)
library(cowplot)

# Get dataset from Box
full_data <- read_csv('C:/Users/jornstein/Box/data/california_finance/City_Expenditures.csv')

# Examples
exmpl <- full_data %>% 
  filter(`Entity Name` == 'La Canada Flintridge',
         `Fiscal Year` == 2017,
         Value > 0)

exmpl2 <- full_data %>% 
  filter(`Entity Name` == 'Beaumont',
         `Fiscal Year` == 2013,
         Value > 0)

# Reshape
data <- full_data %>%
  #select(-c(Type, Category, `Subcategory 1`, `Subcategory 2`, `Line Description`)) %>% 
  select(`Entity Name`, `Fiscal Year`, `Line Description`, Value) %>% 
  pivot_wider(id_cols = c(`Entity Name`, `Fiscal Year`), 
              names_from = `Line Description`, 
              values_from = Value,
              values_fn = list(Value = sum))

# Merge with population
pop <- full_data %>% 
  select(`Entity Name`, `Fiscal Year`, `Estimated Population`) %>% 
  unique

data <- left_join(data, pop, by = c('Entity Name', 'Fiscal Year'))


# Total Expenditures -----

data$total_expenditures <- data %>% 
  select(-c(`Entity Name`, `Fiscal Year`, `Estimated Population`)) %>% 
  rowSums(na.rm = TRUE)

# # check that the sums computed correctly
# data %>% filter(`Entity Name` == 'La Canada Flintridge',
#                 `Fiscal Year` == 2017) %>% 
#   select(total_expenditures)
# sum(exmpl$Value)
# 
# data %>% filter(`Entity Name` == 'Beaumont',
#                 `Fiscal Year` == 2013) %>% 
#   select(total_expenditures)
# sum(exmpl2$Value)

data <- data %>% 
  mutate(total_expenditures_pc = total_expenditures / `Estimated Population`)

city <- 'San Diego'
ggplot(data = data %>% 
         filter(`Entity Name` == city), 
       mapping = aes(x=`Fiscal Year`, y=total_expenditures_pc)) +
  geom_point(alpha = 0.5) +
  geom_smooth() +
  theme_bw() +
  ylab('Total Expenditures Per Capita')

## Police Expenditures ----

police_variable_names <- names(data)[names(data) %>%
                                       tolower %>% 
                                       str_detect('police')]

data$police_expenditures <- data[,police_variable_names] %>% 
  rowSums(na.rm = TRUE)

data <- data %>% 
  mutate(police_expenditures_pc = police_expenditures / `Estimated Population`)

city <- 'San Francisco'
ggplot(data = data %>% 
         filter(`Entity Name` == city), 
       mapping = aes(x=`Fiscal Year`, y = police_expenditures_pc)) +
  geom_point(alpha = 0.5) +
  geom_smooth() +
  theme_bw() +
  ylab('Police Expenditures Per Capita')

## Parks and Recreation Spending ----

parks_and_rec_variable_names <- names(data)[names(data) %>%
                                              tolower %>% 
                                              str_detect('parks')]

data$parks_and_rec_expenditures <- data[,parks_and_rec_variable_names] %>% 
  rowSums(na.rm = TRUE)

data <- data %>% 
  mutate(parks_and_rec_expenditures_pc = parks_and_rec_expenditures / `Estimated Population`)

city <- 'Palo Alto'
ggplot(data = data %>% 
         filter(`Entity Name` == city), 
       mapping = aes(x=`Fiscal Year`, y = parks_and_rec_expenditures_pc)) +
  geom_point(alpha = 0.5) +
  geom_smooth() +
  theme_bw() +
  ylab('Parks and Recreation Expenditures Per Capita')


# Police-to-Parks Ratio ----

city <- 'Menlo Park'
ggplot(data = data %>% 
         filter(`Entity Name` == city), 
       mapping = aes(x=`Fiscal Year`, 
                     y = police_expenditures / parks_and_rec_expenditures)) +
  geom_point(alpha = 0.5) +
  geom_smooth() +
  theme_bw() +
  ylab('Police-to-Parks Ratio')


# Grid ----

plot_pp_ratio <- function(data, cityname){
  
  parks <- ggplot(data = data %>% 
                    filter(`Entity Name` == cityname), 
                  mapping = aes(x=`Fiscal Year`, 
                                y = parks_and_rec_expenditures_pc)) +
    geom_point(alpha = 0.5) +
    geom_smooth(color = 'green', se = FALSE) +
    theme_bw() +
    ylab('Parks Spending Per Capita')
  
  police <- ggplot(data = data %>% 
                     filter(`Entity Name` == cityname), 
                   mapping = aes(x=`Fiscal Year`, 
                                 y = police_expenditures_pc)) +
    geom_point(alpha = 0.5) +
    geom_smooth(color = 'blue', se = FALSE) +
    theme_bw() +
    ylab('Police Spending Per Capita')
  
  pp_ratio <- ggplot(data = data %>% 
                       filter(`Entity Name` == cityname), 
                     mapping = aes(x=`Fiscal Year`, 
                                   y = police_expenditures / parks_and_rec_expenditures)) +
    geom_point(alpha = 0.5) +
    geom_smooth(color = 'black', se = FALSE) +
    theme_bw() +
    ylab('Police-to-Parks Ratio')
  
  plot_grid(police, parks, pp_ratio, ncol = 2)
}

plot_pp_ratio(data, 'Los Angeles')
plot_pp_ratio(data, 'Palo Alto')
plot_pp_ratio(data, 'East Palo Alto')
plot_pp_ratio(data, 'Beverly Hills')
plot_pp_ratio(data, 'Atherton')
plot_pp_ratio(data, 'Mountain View')
plot_pp_ratio(data, 'San Jose')
plot_pp_ratio(data, 'Los Altos')
plot_pp_ratio(data, 'San Mateo')
plot_pp_ratio(data, 'Daly City')
plot_pp_ratio(data, 'Oakland')
plot_pp_ratio(data, 'Alameda')
plot_pp_ratio(data, 'Berkeley')


## All Cities ----

all_cities <- data %>% 
  group_by(`Fiscal Year`) %>% 
  summarise(total_parks_spending = sum(parks_and_rec_expenditures),
            total_police_spending = sum(police_expenditures),
            total_population = sum(na.omit(`Estimated Population`))) %>% 
  mutate(total_police_pc = total_police_spending / total_population,
         total_parks_pc = total_parks_spending / total_population)

ggplot(all_cities,
       aes(x=`Fiscal Year`, y=total_police_pc)) + 
  geom_point() +
  geom_smooth() + 
  theme_bw()

ggplot(all_cities,
       aes(x=`Fiscal Year`, y=total_parks_pc)) + 
  geom_point() +
  geom_smooth() + 
  theme_bw()

ggplot(all_cities,
       aes(x=`Fiscal Year`, y=total_police_spending/total_parks_spending)) + 
  geom_point() +
  geom_smooth() + 
  theme_bw()

# ## Police as share of spending ----
# 
# data <- data %>% 
#   mutate(police_share = police_expenditures / total_expenditures * 100)
# 
# city <- 'Covina'
# ggplot(data = data %>% 
#          filter(`Entity Name` == city), 
#        mapping = aes(x=`Fiscal Year`, y = police_share)) +
#   geom_point(alpha = 0.5) +
#   geom_smooth() +
#   theme_bw() +
#   ylab('Share of Expenditures on Police')
