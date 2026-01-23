# Test whether two strings match with an LLM prompt.

Test whether two strings match with an LLM prompt.

## Usage

``` r
check_match(
  string1,
  string2,
  model = "gpt-5.2",
  record_type = "entity",
  instructions = NULL,
  openai_api_key = Sys.getenv("OPENAI_API_KEY"),
  parallel = TRUE
)
```

## Arguments

- string1:

  A string or vector of strings

- string2:

  A string or vector of strings

- model:

  Which LLM to prompt; defaults to 'gpt-4o-2024-11-20'

- record_type:

  A character describing what type of entity `string1` and `string2`
  represent. Should be a singular noun (e.g. "person", "organization",
  "interest group", "city").

- instructions:

  A string containing additional instructions to include in the LLM
  prompt.

- openai_api_key:

  Your OpenAI API key. By default, looks for a system environment
  variable called "OPENAI_API_KEY" (recommended option). Otherwise, it
  will prompt you to enter the API key as an argument.

- parallel:

  TRUE to submit API requests in parallel. Setting to FALSE can reduce
  rate limit errors at the expense of longer runtime.

## Value

A vector the same length as `string1` and `string2`. "Yes" if the pair
of strings match, "No" otherwise.

## Examples

``` r
if (FALSE) { # \dontrun{
check_match('UPS', 'United Parcel Service')
check_match('UPS', 'United States Postal Service')
check_match(c('USPS', 'USPS', 'USPS'),
            c('Post Office', 'United Parcel', 'US Postal Service'))
} # }
```
