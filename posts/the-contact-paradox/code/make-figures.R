# Make figures from SIR experiments
# Author: Joe Ornstein
# Date: April 27, 2020

library(tidyverse)
source('sir-model.R')

## Load Parameters ----

load('output/parameters.RData')

## Plot representative run ----

i <- 34
load(paste0('output/data_', i, '.RData'))

plot_curves(data, 
            title = paste0('Degree Dist = ', parameters$dist[i], 
                           ', Pct. Tested = ', parameters$pct_tested[i],
                           ', Target = ', parameters$target[i]))

## Compare random targeting to contact targeting ----

load('output/data_1.RData')
run_length <- max(data$tick)
num_agents <- sum(data[1,])

parameters$cumulative_infections <- NA

# Get cumulative infection rates
for(i in 1:nrow(parameters)){
  
  load(paste0('output/data_', i, '.RData'))
  
  parameters$cumulative_infections[i] <- 
    (num_agents - data[run_length + 1,]$S) / num_agents
  
}

# Summarise data, grouped by degree distribtuion, target, and pct_tested
data <- parameters %>% 
  group_by(dist, target, pct_tested) %>%
  summarise(mean_cumulative_infections = mean(cumulative_infections),
            min_cumulative_infections = min(cumulative_infections),
            max_cumulative_infections = max(cumulative_infections))


## Plot Results ----

# Setup Plot
p <- ggplot() +
  xlab('Daily Tests (%)') + ylab('Cumulative Infections (%)') + 
  theme_classic() +
  theme(legend.title = element_blank())

# Normal Distribution
p_normal <- p + 
  geom_line(data = data %>%
              filter(dist == 'normal',
                     target == 'random'),
            aes(x = pct_tested * 100, 
                y = mean_cumulative_infections * 100,
                linetype = 'Random Targeting')) + 
  geom_line(data = data %>%
              filter(dist == 'normal',
                     target == 'contacts'),
            aes(x = pct_tested * 100, 
                y = mean_cumulative_infections * 100,
                linetype = 'Contact Targeting'))

ggsave('figs/normal_results.png', plot = p_normal) 

# Lognormal Distribution

p_lognormal <- p + 
  geom_line(data = data %>%
              filter(dist == 'log-normal',
                     target == 'random'),
            aes(x = pct_tested * 100, 
                y = mean_cumulative_infections * 100,
                linetype = 'Random Targeting')) + 
  geom_line(data = data %>%
              filter(dist == 'log-normal',
                     target == 'contacts'),
            aes(x = pct_tested * 100, 
                y = mean_cumulative_infections * 100,
                linetype = 'Contact Targeting'))

ggsave('figs/lognormal_results.png', plot = p_lognormal)

# Gamma Distribution
p_gamma <- p + 
  geom_line(data = data %>%
              filter(dist == 'gamma',
                     target == 'random'),
            aes(x = pct_tested * 100, 
                y = mean_cumulative_infections * 100,
                linetype = 'Random Targeting')) + 
  geom_line(data = data %>%
              filter(dist == 'gamma',
                     target == 'contacts'),
            aes(x = pct_tested * 100, 
                y = mean_cumulative_infections * 100,
                linetype = 'Contact Targeting'))

p_gamma  

ggsave('figs/gamma_results.png', plot = p_gamma)


## Plot degree distributions ----

# Parameters
mean_degree <- 12
sd_degree <- 2.5
sd_lognormal <- 10
alpha <- 0.25
num_agents <- 10000

# Set seed for reproducibility
set.seed(1)

# Normal distribution
normal_dist <- rnorm(num_agents, mean_degree, sd_degree) %>% round
png('figs/normal_distribution.png', res = 150, height = 800, width = 800)
hist(normal_dist, xlab = 'Node Degree', main = '')
dev.off()

# Log-normal distribution
# thanks https://msalganik.wordpress.com/2017/01/21/making-sense-of-the-rlnorm-function-in-r/
# for parameterization
m <- mean_degree
s <- sd_lognormal
location <- log(m^2 / sqrt(s^2 + m^2))
shape <- sqrt(log(1 + (s^2 / m^2)))
lognormal_dist <- round(
  rlnorm(num_agents, 
         meanlog = location, 
         sdlog = shape)
)
# Replace any zeroes with 1 (everyone must have at least one connection)
lognormal_dist <- if_else(lognormal_dist == 0, 1, lognormal_dist)

png('figs/lognormal_distribution.png', res = 150, height = 800, width = 800)
hist(lognormal_dist, xlab = 'Node Degree', main = '')
dev.off()



# Gamma distribution
gamma_dist <- round(rgamma(num_agents, shape = alpha, scale = (mean_degree - 1) / alpha) + 1)
png('figs/gamma_distribution.png', res = 150, height = 800, width = 800)
hist(gamma_dist, xlab = 'Node Degree', main = '')
dev.off()

