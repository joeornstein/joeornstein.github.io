# Get pretrained text embeddings

Get pretrained text embeddings from the OpenAI or Mistral API.
Automatically batches requests to handle rate limits.

## Usage

``` r
get_embeddings(
  text,
  model = "text-embedding-3-large",
  dimensions = 256,
  openai_api_key = Sys.getenv("OPENAI_API_KEY"),
  parallel = TRUE
)
```

## Arguments

- text:

  A character vector

- model:

  Which embedding model to use. Defaults to 'text-embedding-3-large'.

- dimensions:

  The dimension of the embedding vectors to return. Defaults to 256.
  Note that the 'mistral-embed' model will always return 1024 vectors.

- openai_api_key:

  Your OpenAI API key. By default, looks for a system environment
  variable called "OPENAI_API_KEY".

- parallel:

  TRUE to submit API requests in parallel. Setting to FALSE can reduce
  rate limit errors at the expense of longer runtime.

## Value

A matrix of embedding vectors (one per row).

## Examples

``` r
if (FALSE) { # \dontrun{
embeddings <- get_embeddings(c('dog', 'cat', 'canine', 'feline'))
embeddings['dog',] |> dot(embeddings['canine',])
embeddings['dog',] |> dot(embeddings['feline',])
} # }
```
