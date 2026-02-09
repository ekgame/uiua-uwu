# Experimental!

~ "../uwu-utils/lib.ua" ~ Strings

# Defines headers (key-value pairs) for HTTP messages.
# Expects to be struct of arrays of {Name Value} pairs.
┌─╴Headers
  ~ {Name Value}

  # Expect a single header with the given name, return its value.
  # Throws an error if there are zero more headers with the given name.
  # Value ? HeaderName Headers
  ExpectOne ← (
    ⤚(▽⊃(=⊓(□|Name)|⋅Value))
    ⟜(⍤$"Expected one '_' header, but got _" ⊃(⋅∘|⧻|=1⧻))
    °□⊢
  )

  # Parse headers from a string.
  # Headers ? String
  FromString ← Headers ⍚(⊙Strings~Trim °$"_:_")

  # Attempt to get declared content length from headers.
  # Throws an error if Content-Length header is no present or invalid.
  # Int ? Headers
  GetContentLength ← (
    Headers~ExpectOne "Content-Length"
    ⍣(⋕|⍤"'Content-Length' must be a number"0)
    ⟜(⍤"'Content-Length' must be zero or positive"≥0)
    ⟜(⍤"'Content-Length' must be an integer"=⊸⁅)
  )

  # Get declared transfer encodings from headers.
  # ListOfEncodings ? Headers
  GetTransferEncodings ← ⍣(¯⌵ ≡Strings~Trim °/$"_,_" Headers~ExpectOne "Transfer-Encoding"|{})

  # Infer whether the request body should be read in chunked mode.
  # Bool ? Headers
  IsChunked ← ˜∊ □"chunked" GetTransferEncodings

  # Dump headers to a string.
  Dump ← /$"_\r\n_" ⍚$"_: _" °Headers
└─╴

# Represents an HTTP request header parsed from a raw byte stream,
# without any validation, normalization, or path decoding applied.
┌─╴RawHttpRequestHeader
  ~ {Method Path Headers}

  # Dump the request header to a string.
  # String ? RawHttpRequestHeader
  Dump ← $"_\r\n_" ⊃($"_ _ HTTP/1.1" ⊃Method Path|Headers~Dump Headers)
└─╴

# Defines strategies for reading the body of an HTTP message from a byte stream.
┌─╴BodyReadingStrategy
  |Empty
  |ContentLength {Length}
  |Chunked

  # Infer a strategy for reading the body of an HTTP request based on its headers.
  # Body ? RawHttpRequestHeader
  InferBodyReadingStrategyFromRequest ← ⍣(
    Chunked °1 RawHttpRequestHeader~Headers≈IsChunked
  | ContentLength RawHttpRequestHeader~Headers≈GetContentLength
  | Empty
  )

  # Read the body of an HTTP message from a byte stream given a strategy.
  # Bytes ? BodyReadingStrategy StreamHandle
  ReadBodyFromStream ← ⍣(
    [] ◌ °Empty
  | ⍩&rb °ContentLength
  | °Chunked
    # TODO: implement chunked transfer decoding
    ⍤"Chunked body decoding is currently unsupported"0
  )
└─╴

# Represents a raw HTTP request parsed from a byte stream, without any validation, normalization.
┌─╴RawHttpRequest
  ~ {RawHttpRequestHeader Body}

  # Dump HTTP request to a byte array suitable for sending over a network.
  # ByteArray ? RawHttpRequest
  ToBytes ← ⊂⊃(utf₈ ˜⊂"\r\n\r\n" RawHttpRequestHeader~Dump RawHttpRequestHeader|Body)
└─╴

# Represents a parsed and validated HTTP request or a request built programmatically.
┌─╴HttpRequest
  ~ {Method Path Query Headers Body}

  # TODO: Validate method
  # TODO: Decode path
  # TODO: Decide on body type (ByteArray or String) from Content-Type header
  # TODO: Truncate body to Content-Length if present, throw error if body is shorter than Content-Length
  # FromRaw ← (
  #   ~Properties {
  #     NormalizedMethod
  #     HasBody
  #     ContentLength
  #   }

  #   NormalizeMethod ← (
  #     ValidMethods ← {"GET" "HEAD" "POST" "PUT" "DELETE" "CONNECT" "OPTIONS" "TRACE" "PATCH"}
  #     ⟜(⍤$"Unrecognized method: _" ⟜(∊ValidMethods □)) ⌵
  #   )
  #   HasBodyByMethod ← ∊{"POST" "PUT" "PATCH"}□
  #   NormalizePath ← ∘ # TODO: decode URL-encoded path
  #   InferContentLength ← (
  #     # if Content-Length header is present, use it, otherwise use the length of the raw body
  #     ⊃[⬚"-1" RawHttpRequest~GetOneHeaderOrDeault "Content-Length"]
  #   )

  #   ⊃(⟜HasBodyByMethod NormalizeMethod RawHttpRequest~Method
  #   | InferContentLength)
  # )
└─╴

# Parses an HTTP request from a byte stream.
# Will throw an error if the request is malformed.
# RawHttpRequest ? StreamHandle
ParseRequestFromStream ← (
  # RawHttpRequestHeader ? String
  ParseRequestHeader ← (
    ParseRequestLine ← ⊙⊙◌ °$"_ _ _"
    SplitLines ← °/$"_\r\n_"
  
    °⊂ SplitLines
    ⊓(ParseRequestLine|Headers~FromString)
    RawHttpRequestHeader
  )

  ParseRequestHeader ↘¯4 ⊸&ru "\r\n\r\n"
  ⟜BodyReadingStrategy!(ReadBodyFromStream InferBodyReadingStrategyFromRequest)
  RawHttpRequest
)
