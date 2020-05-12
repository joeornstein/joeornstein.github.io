# Run SIR model and save results
# Author: Joe Ornstein
# Date: April 27, 2020

## Load SIR Model Functions ----

source('sir-model.R')

## Create parameters file ----

parameters <- expand.grid(rep = 1:20,
                          pct_tested = seq(0, 0.3, 0.02),
                          dist = c('normal', 'log-normal', 'gamma'),
                          target = c('random', 'contacts'))

save(parameters, file = 'output/parameters.RData')

## Run experiments ----

for(i in 1:nrow(parameters)){
  
  # Run the model for each parameter row.
  data <- execute_model(dist = parameters$dist[i],
                        target = parameters$target[i],
                        pct_tested = parameters$pct_tested[i],
                        random_seed = parameters$rep[i],
                        verbose = FALSE)
  
  
  # Save data to output/ folder
  save(data, file = paste0('output/data_', i, '.RData'))
  
  print(paste0('Run ', i, ' complete!'))
  print(Sys.time())
  
}
