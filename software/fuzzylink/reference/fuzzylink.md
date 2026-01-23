# Probabilistic Record Linkage Using Pretrained Text Embeddings

Probabilistic Record Linkage Using Pretrained Text Embeddings

## Usage

``` r
fuzzylink(
  dfA,
  dfB,
  by,
  blocking.variables = NULL,
  verbose = TRUE,
  record_type = "entity",
  instructions = NULL,
  model = "gpt-4.1",
  openai_api_key = Sys.getenv("OPENAI_API_KEY"),
  embedding_dimensions = 256,
  embedding_model = "text-embedding-3-large",
  learner = "glm",
  fmla = match ~ sim + jw,
  max_labels = 10000,
  parallel = TRUE,
  return_all_pairs = FALSE
)
```

## Arguments

- dfA, dfB:

  A pair of data frames or data frame extensions (e.g. tibbles)

- by:

  A character denoting the name of the variable to use for fuzzy
  matching

- blocking.variables:

  A character vector of variables that must match exactly in order to
  match two records

- verbose:

  TRUE to print progress updates, FALSE for no output

- record_type:

  A character describing what type of entity the `by` variable
  represents. Should be a singular noun (e.g. "person", "organization",
  "interest group", "city").

- instructions:

  A string containing additional instructions to include in the LLM
  prompt during validation.

- model:

  Which LLM to prompt when validating matches; defaults to 'gpt-4.1'

- openai_api_key:

  Your OpenAI API key. By default, looks for a system environment
  variable called "OPENAI_API_KEY" (recommended option). Otherwise, it
  will prompt you to enter the API key as an argument.

- embedding_dimensions:

  The dimension of the embedding vectors to retrieve. Defaults to 256

- embedding_model:

  Which pretrained embedding model to use; defaults to
  'text-embedding-3-large' (OpenAI), but will also accept
  'mistral-embed' (Mistral).

- learner:

  Which supervised learner should be used to predict match
  probabilities. Defaults to logistic regression ('glm'), but will also
  accept random forest ('ranger').

- fmla:

  By default, logistic regression model predicts whether two records
  match as a linear combination of embedding similarity and Jaro-Winkler
  similarity (`match ~ sim + jw`). Change this input for alternate
  specifications.

- max_labels:

  The maximum number of LLM prompts to submit when labeling record
  pairs. Defaults to 10,000

- parallel:

  TRUE to submit API requests in parallel. Setting to FALSE can reduce
  rate limit errors at the expense of longer runtime.

- return_all_pairs:

  If TRUE, returns *every* within-block record pair from dfA and dfB,
  not just validated pairs. Defaults to FALSE.

## Value

A dataframe with all rows of `dfA` joined with any matches from `dfB`

## Examples

``` r
if (FALSE) { # \dontrun{
dfA <- data.frame(state.x77)
dfA$name <- rownames(dfA)
dfB <- data.frame(name = state.abb, state.division)
df <- fuzzylink(dfA, dfB,
                by = 'name',
                record_type = 'US state government',
                instructions = 'The second dataset contains US postal codes.')
} # }
```
