# Create matrix of embedding similarities

Create a matrix of pairwise similarities between each string in
`strings_A` and `strings_B`.

## Usage

``` r
get_similarity_matrix(embeddings, strings_A = NULL, strings_B = NULL)
```

## Arguments

- embeddings:

  A matrix of text embeddings

- strings_A:

  A string vector

- strings_B:

  A string vector

## Value

A matrix of cosine similarities between the embeddings of strings_A and
the embeddings of strings_B

## Examples

``` r
if (FALSE) { # \dontrun{
embeddings <- get_embeddings(c('UPS', 'USPS', 'Postal Service'))
get_similarity_matrix(embeddings)
get_similarity_matrix(embeddings, 'Postal Service')
get_similarity_matrix(embeddings, 'Postal Service', c('UPS', 'USPS'))
} # }
```
