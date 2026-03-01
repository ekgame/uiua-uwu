# Experimental!
Http ~ "../../uwu-http/lib.ua"

# This script downloads and formats known MIME types from the Apache HTTP Server project.
# The MIME types are saved to a CSV file, which is then loaded by the server at runtime.

MimeTypesSource ← $ https://raw.githubusercontent.com/apache/httpd/refs/heads/trunk/docs/conf/mime.types

# TODO: replace with a http client, when we have one
GetMimeTypes ← (
  Http~BuildRequest!(
    Url MimeTypesSource
    AddHeader "Connection" "close"
  )
  Http~RawRequest~ToBytes Http~Request~ToRawRequest
  ⍜(&tlsc "raw.githubusercontent.com:443"|Http~ParseResponseFromStream ˜⊸&w)
  °utf₈ Http~Response~Body
)

# Get all mime types and split by new line
°/$"_\n_" GetMimeTypes

# Remove comments and empty lines
▽⊸≡◇⍣(0 °""|0 °@#⊢|1)

# Process and format into CSV string
⍚(⊜□ ⊸≠@\s ⍜⊜∘⋅@\s ⊸=@\t)
/$"_\n_" ⍚(/$"_\n_" ⍚˜$"_,_" ¤°⊂)

# Save to file
&fwa $"_/../resources/mime\_types.csv" ThisFileDir
