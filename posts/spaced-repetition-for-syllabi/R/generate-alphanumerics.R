# Generate random alphanumeric strings (license plates)
# Author: Joe Ornstein
# Version: 1.0
# Date: June 4, 2020

library(tidyverse)
library(stringi)

set.seed(42)

num <- 100

license_plates <- stri_paste(
  stri_rand_strings(n = num, length = 1, pattern = '[A-Z]'),
  stri_rand_strings(n = num, length = 1, pattern = '[A-Z]'),
  stri_rand_strings(n = num, length = 1, pattern = '[0-9]'),
  '-',
  stri_rand_strings(n = num, length = 1, pattern = '[A-Z]'),
  stri_rand_strings(n = num, length = 1, pattern = '[0-9]'),
  stri_rand_strings(n = num, length = 1, pattern = '[A-Z]'))


# write to csv
tibble(license_plates) %>% 
  write_csv('content/posts/spaced-repetition-for-syllabi/data/master.csv')
