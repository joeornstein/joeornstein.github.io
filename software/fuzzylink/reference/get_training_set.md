# Create a training set

Creates a training set from a list of similarity matrices and labels it
using a zero-shot GPT prompt.

## Usage

``` r
get_training_set(
  sim,
  num_bins = 50,
  samples_per_bin = 10,
  n = 500,
  record_type = "entity",
  instructions = NULL,
  model = "gpt-3.5-turbo-instruct",
  openai_api_key = Sys.getenv("OPENAI_API_KEY"),
  parallel = TRUE
)
```

## Arguments

- sim:

  A matrix of similarity scores

- num_bins:

  Number of bins to split similarity scores for stratified random
  sampling (defaults to 50)

- samples_per_bin:

  Number of string pairs to sample from each bin (defaults to 5)

- n:

  Sample size for the training dataset

- record_type:

  A character describing what type of entity the rows and columns of
  `sim` represent. Should be a singular noun (e.g. "person",
  "organization", "interest group", "city").

- instructions:

  A string containing additional instructions to include in the LLM
  prompt during validation.

- model:

  Which OpenAI model to prompt; defaults to 'gpt-3.5-turbo-instruct'

- openai_api_key:

  Your OpenAI API key. By default, looks for a system environment
  variable called "OPENAI_API_KEY" (recommended option). Otherwise, it
  will prompt you to enter the API key as an argument.

- parallel:

  TRUE to submit API requests in parallel. Setting to FALSE can reduce
  rate limit errors at the expense of longer runtime.

## Value

A dataset with string pairs `A` and `B`, along with a `match` column
indicating whether they match.
