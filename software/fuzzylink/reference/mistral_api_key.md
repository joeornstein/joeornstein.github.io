# Install a MISTRAL API KEY in Your `.Renviron` File for Repeated Use

This function will add your Mistral API key to your `.Renviron` file so
it can be called securely without being stored in your code. After you
have installed your key, it can be called any time by typing
`Sys.getenv("MISTRAL_API_KEY")` and will be automatically called in
package functions. If you do not have an `.Renviron` file, the function
will create one for you. If you already have an `.Renviron` file, the
function will append the key to your existing file, while making a
backup of your original file for disaster recovery purposes.

## Usage

``` r
mistral_api_key(key, overwrite = FALSE, install = FALSE)
```

## Arguments

- key:

  The API key provided to you from Mistral formated in quotes. A key can
  be acquired at <https://console.mistral.ai/api-keys/>

- overwrite:

  If this is set to TRUE, it will overwrite an existing MISTRAL_API_KEY
  that you already have in your `.Renviron` file.

- install:

  if TRUE, will install the key in your `.Renviron` file for use in
  future sessions. Defaults to FALSE.

## Value

No return value, called for side effects.

## Examples

``` r
if (FALSE) { # \dontrun{
mistral_api_key("111111abc", install = TRUE)
# First time, reload your environment so you can use the key without restarting R.
readRenviron("~/.Renviron")
# You can check it with:
Sys.getenv("MISTRAL_API_KEY")
} # }

if (FALSE) { # \dontrun{
# If you need to overwrite an existing key:
mistral_api_key("111111abc", overwrite = TRUE, install = TRUE)
# First time, reload your environment so you can use the key without restarting R.
readRenviron("~/.Renviron")
# You can check it with:
Sys.getenv("MISTRAL_API_KEY")
} # }
```
