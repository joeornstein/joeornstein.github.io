# SIR Model on network
# Compare random testing with testing contacts
# Author: Joe Ornstein
# Date: April 22, 2020


## Libraries ----

library(tidyverse)
library(igraph)

## Functions -----

# Function to sample one item from list (even if the list has only one item)
sampleWithoutSurprises <- function(x) {
  if (length(x) <= 1) {
    return(x)
  } else {
    return(sample(x,1))
  }
}

## Core Model Loop ----

execute_model <- function(num_agents = 10000,
                          R0 = 2.5, 
                          infection_duration = 15, 
                          initial_prevalence = 0.001, 
                          mean_degree = 12,
                          sd_degree = 2.5,
                          alpha = 0.25,
                          sd_lognormal = 10,
                          dist = 'gamma',
                          pct_tested = 0.0, 
                          target = 'random',
                          run_length = 180, 
                          random_seed = NA,
                          verbose = FALSE){
  
  
  if(!is.na(random_seed)) set.seed(random_seed) # set random seed for reproducibility
  
  # Setup agents
  agents <- tibble(ID = 1:num_agents,
                   state = ifelse(runif(num_agents, 0, 1) < initial_prevalence,
                                  'I', 'S'),
                   time_infected = 0)
  
  # Setup Network with specified degree distribution
  if(dist == 'normal'){
    # normal distribution
    degree_dist <- rnorm(num_agents, mean_degree, sd_degree) %>% round
  }
  if(dist == 'gamma'){
    # gamma distribution (+1 so every agent has at least one connection)
    degree_dist <- round(rgamma(num_agents, shape = alpha, scale = (mean_degree - 1) / alpha) + 1)
  }
  if(dist == 'log-normal'){
    # log-normal distribution 
    # thanks https://msalganik.wordpress.com/2017/01/21/making-sense-of-the-rlnorm-function-in-r/
    # for parameterization
    m <- mean_degree
    s <- sd_lognormal
    location <- log(m^2 / sqrt(s^2 + m^2))
    shape <- sqrt(log(1 + (s^2 / m^2)))
    degree_dist <- round(
      rlnorm(num_agents, 
             meanlog = location, 
             sdlog = shape)
      )
    
    # Replace any zeroes with 1 (everyone must have at least one connection)
    degree_dist <- if_else(degree_dist == 0, 1, degree_dist)
  }
  
  if(sum(degree_dist) %% 2 == 1) degree_dist[1] <- degree_dist[1] + 1
  g <- sample_degseq(degree_dist)
  
  # neighbor list
  contacts <- adjacent_vertices(g, agents$ID)
  
  # Compute tranmission probability based on R_0, infection duration, and mean node degree
  transmission_probability <- R0 / mean_degree / infection_duration
  
  ticks <- 0
  
  data <- agents %>% 
    group_by(state) %>%
    summarise(num = n()) %>%
    mutate(tick = ticks)
  
  while(ticks < run_length){
    
    if(verbose){
      num_infected <- agents %>% filter(state == 'I') %>% nrow
      print(paste0(num_infected, ' infected, day ', ticks))
    }
    
    # test random agents and remove the positives
    if(target == 'random'){
      agents <- agents %>%
        mutate(tested = runif(num_agents, 0 ,1) < pct_tested) %>%
        mutate(state = ifelse(tested & state == 'I', 'R', state))
      
      if(verbose & sum(agents$tested) > 0){
        mean_degree <- mean(degree_dist[agents[agents$tested,]$ID])
        print(paste0('Mean Degree of Agents Tested: ', mean_degree))
      }
    }
    
    # test *contacts* of random agents and remove the positives
    if(target == 'contacts'){
     
      # select index agents at random
      agents <- agents %>%
        mutate(contacted = runif(num_agents, 0, 1) < pct_tested)
      
      index_agents <- agents[agents$contacted,]$ID
      
      
      if(length(index_agents) > 0){
        
        # Sample pct_tested*num_agents agents from the list of contacts
        agents_to_test <- contacts[index_agents] %>%
          unlist %>%
          sample(size = length(index_agents))
        
        # test the contacts and remove positives
        agents <- agents %>%
          mutate(tested = ID %in% agents_to_test) %>%
          mutate(state = ifelse(tested & state == 'I', 'R', state))
      }
      
      if(verbose){
        mean_degree <- mean(degree_dist[agents_to_test])
        print(paste0("Mean Degree of Agents Tested: ", mean_degree))
      }
      
    }
    
    
    
    
    # infected agents infect
    infected_IDs <- agents[agents$state == 'I',]$ID # get IDs
    contacts_to_infect <- adjacent_vertices(g, infected_IDs) %>% 
      unlist # get contacts
    
    random_numbers <- runif(length(contacts_to_infect), 0, 1)
    
    # infect with probability = transmission_probability
    new_infections <- contacts_to_infect[random_numbers < transmission_probability]
    
    if(length(new_infections) > 0){
      agents <- agents %>%
        mutate(state = ifelse(state == 'S' & ID %in% new_infections,
                              'I', state))
    }
    
    # increment time_infected; infecteds recover
    agents <- agents %>%
      mutate(time_infected = ifelse(state == 'I', time_infected + 1, 0),
             state = ifelse(state == 'I' & time_infected >= infection_duration,
                            'R', state))
    
    # increment ticks
    ticks <- ticks + 1
    
    # Append data
    data <- agents %>%
      group_by(state) %>%
      summarise(num = n()) %>%
      mutate(tick = ticks) %>%
      bind_rows(data, .)
    
  }
  
  
  # Convert data to time series
  data <- data %>% 
    pivot_wider(values_from = num,
                names_from = state,
                values_fill = list(num = 0))
  return(data)

}


## Plot Data ----

plot_curves <- function(data, title = ''){
  
  
  num_agents <- rowSums(data[1,])
  
  p <- ggplot(data) + 
    geom_line(aes(x=tick, y=R/num_agents), colour = 'black') +
    geom_line(aes(x=tick, y=I/num_agents), colour = 'red') +
    xlab('Day') + ylab('Infections') + theme_bw() +
    ggtitle(title)
  
  return(p)
}

## Send default parameters to global environment ----

to_environment <- function(x) {
  if(is.list(x)) { 
    list2env(x, envir = .GlobalEnv)
    lapply(x, to_environment)
  }
}

debug_time <- TRUE
if(debug_time) execute_model %>% formals %>% as.list %>% to_environment

