# Experimental!

~ "../uwu-utils/lib.ua" ~ Strings
Assert ~ "../uwu-assert/lib.ua"

# Defines headers (key-value pairs) for HTTP messages.
# Expects to be struct of arrays of {Name Value} pairs.
┌─╴Headers
  ~ {
    Name: Assert!List!String
    Value: Assert!List!String
  }

  # Expect a single header with the given name, return its value.
  # Throws an error if there are zero more headers with the given name.
  # Value ? HeaderName Headers
  ExpectOne ← (
    ⤚(▽⊃(=⊓(□|Name)|⋅Value))
    ⟜(⍤$"Expected one '_' header, but got _" ⊃(⋅∘|⧻|=1⧻))
    °□⊢
  )

  # Parse headers from a string.
  # Headers ? List!String
  FromStringLines ← (
    ⊸Assert!List!String
    Headers ⍚(⊙Strings~Trim °$"_:_")
  )

  # Attempt to get declared content length from headers.
  # Throws an error if Content-Length header is no present or invalid.
  # Int ? Struct!Headers
  GetContentLength ← (
    ⊸Assert!Struct!Headers
    Headers~ExpectOne "Content-Length"
    ⍣(⋕|⍤"'Content-Length' must be a number"0)
    ⟜(⍤"'Content-Length' must be zero or positive"≥0)
    ⟜(⍤"'Content-Length' must be an integer"=⊸⁅)
  )

  # Get declared transfer encodings from headers.
  # ListOfEncodings ? Struct!Headers
  GetTransferEncodings ← (
    ⊸Assert!Struct!Headers
    ⍣(¯⌵ ≡Strings~Trim °/$"_,_" Headers~ExpectOne "Transfer-Encoding"|{})
  )

  # Infer whether the request body should be read in chunked mode.
  # Bool ? Headers
  IsChunked ← (
    ⊸Assert!Struct!Headers
    ˜∊ □"chunked" GetTransferEncodings
  )

  # Dump headers to a string.
  # String ? Struct!Headers
  Dump ← (
    ⊸Assert!Struct!Headers
    /$"_\r\n_" ⍚$"_: _" °Headers
  )
└─╴

# Represents an HTTP request header parsed from a raw byte stream,
# without any validation, normalization, or path decoding applied.
┌─╴RawHttpRequestHeader
  ~ {
    Method: Assert!String
    Path: Assert!String
    Headers: Assert!Struct!Headers
  }

  # Dump the request header to a string.
  # String ? RawHttpRequestHeader
  Dump ← (
    ⊸Assert!Struct!RawHttpRequestHeader
    $"_\r\n_" ⊃($"_ _ HTTP/1.1" ⊃Method Path|Headers~Dump Headers)
  )
└─╴

# Represents an HTTP response header parsed from a raw byte stream,
# without any validation, normalization, or path decoding applied.
┌─╴RawHttpResponseHeader
  ~ {
    StatusCode: Assert!Int
    Headers: Assert!Struct!Headers
  }

  # Dump the response header to a string.
  # String ? RawHttpResponseHeader
  Dump ← (
    ⊸Assert!Struct!RawHttpResponseHeader
    $"_\r\n_" ⊃($"HTTP/1.1 _" StatusCode|Headers~Dump Headers)
  )
└─╴

# Defines strategies for reading the body of an HTTP message from a byte stream.
┌─╴BodyReadingStrategy
  |Empty
  |ContentLength {Length: Assert!Int}
  |Chunked

  # Infer a strategy for reading the body of an HTTP request based on its headers.
  # Body ? Struct!Headers
  InferBodyReadingStrategyFromHeaders ← (
    ⊸Assert!Struct!Headers
    ⍣(Chunked °1 Headers~IsChunked
    | ContentLength Headers~GetContentLength
    | Empty
    )
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

  # Read the body from a stream given the headers and the stream.
  # Body ? Struct!Headers StreamHandle
  FromHeadersAndStream ← (
    ◡Assert!⊓(Struct!Headers|StreamHandle)
    InferBodyReadingStrategyFromHeaders
    ReadBodyFromStream
  )
└─╴

# Represents a raw HTTP request parsed from a byte stream, without any validation, normalization.
┌─╴RawHttpRequest
  ~ {
    RawHttpRequestHeader: Assert!Struct!RawHttpRequestHeader
    Body: Assert!ByteArray
  }

  # Dump HTTP request to a byte array suitable for sending over a network.
  # ByteArray ? Struct!RawHttpRequest
  ToBytes ← (
    ⊸Assert!Struct!RawHttpRequest
    ⊂⊃(utf₈ ˜⊂ "\r\n\r\n" RawHttpRequestHeader~Dump RawHttpRequestHeader|Body)
  )

  # Debug dump the request to a string, with the body truncated if it's not valid UTF-8.
  # String ? Struct!RawHttpRequest
  DebugDump ← (
    ⊸Assert!Struct!RawHttpRequest
    ⊂⊃(˜⊂ "\r\n\r\n" RawHttpRequestHeader~Dump RawHttpRequestHeader|⍣(°utf₈|"[binary data]") Body)
  )
└─╴

# Represents a raw HTTP response parsed from a byte stream, without any validation, normalization.
┌─╴RawHttpResponse
  ~ {
    RawHttpResponseHeader: Assert!Struct!RawHttpResponseHeader
    Body: Assert!ByteArray
  }

  # Dump HTTP response to a byte array suitable for sending over a network.
  # ByteArray ? Struct!RawHttpResponse
  ToBytes ← (
    ⊸Assert!Struct!RawHttpResponse
    ⊂⊃(utf₈ ˜⊂ "\r\n\r\n" RawHttpResponseHeader~Dump RawHttpResponseHeader|Body)
  )

  # Debug dump the response to a string, with the body truncated if it's not valid UTF-8.
  # String ? Struct!RawHttpResponse
  DebugDump ← (
    ⊸Assert!Struct!RawHttpResponse
    ⊂⊃(˜⊂ "\r\n\r\n" RawHttpResponseHeader~Dump RawHttpResponseHeader|⍣(°utf₈|"[binary data]") Body)
  )
└─╴

# Represents a parsed and validated HTTP request or a request built programmatically.
┌─╴HttpRequest
  ~ {
    Method: Assert!String
    Path: Assert!String
    Query: Assert!String
    Headers: Assert!Struct!Headers
    Body: Assert!Any!(ByteArray|String)
  }

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
    ⊸Assert!String
    °⊂ °/$"_\r\n_"
    ⊓(⊙⊙◌ °$"_ _ _"
    | Headers~FromStringLines)
    RawHttpRequestHeader
  )

  ⊸Assert!StreamHandle
  ParseRequestHeader ↘¯4 ⊸&ru "\r\n\r\n"
  ⟜(RawHttpRequestHeader~Headers
    BodyReadingStrategy~FromHeadersAndStream
  )
  RawHttpRequest
)

# Parses an HTTP response from a byte stream.
# Will throw an error if the response is malformed.
# RawHttpResponse ? StreamHandle
ParseResponseFromStream ← (
  # RawHttpResponseHeader ? String
  ParseResponseHeader ← (
    ⊸Assert!String
    °⊂ °/$"_\r\n_"
    ⊓(⊡₁ °/$"_ _"
    | Headers~FromStringLines)
    RawHttpResponseHeader
  )

  ⊸Assert!StreamHandle
  ParseResponseHeader ↘¯4 ⊸&ru "\r\n\r\n"
  ⟜(RawHttpResponseHeader~Headers
    BodyReadingStrategy~FromHeadersAndStream
  )
  RawHttpResponse
)
