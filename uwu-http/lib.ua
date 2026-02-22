# Experimental!

~ "../uwu-utils/lib.ua" ~ Strings
Assert ~ "../uwu-assert/lib.ua"

IsStatusCode ← (
  ⟜(/↧ ⊃[≥100|<600] ⊸Assert!Scalar!Int)
  ⍤ $"Expected a valid HTTP status code got _"
)

# Defines headers (key-value pairs) for HTTP messages.
# Expects to be struct of arrays of {Name Value} pairs.
┌─╴Headers
  ~ {
    Name: Assert!List!String
    Value: Assert!List!String
  }

  # Default empty headers struct.
  # Headers ?
  Default ← Headers {} {}

  # Add a header to the headers struct.
  # Headers ? HeaderName HeaderValue Headers
  Add ← (
    ◡Assert!⊓(String|String|Struct!Headers)
    ⍚(˜⊂□) □₂
  )

  # Set a header, replacing any existing headers with the same name.
  # Headers ? HeaderName HeaderValue Headers
  Set ← (
    ◡Assert!⊓(String|String|Struct!Headers)
    Add ⟜₂(⍚▽ ⊸(¤≠⊃(□∘|⋅⋅Name)))
  )

  # Merge header entries from the first headers struct to the second one.
  # The entries from the first struct will override entries in the second struct.
  # Headers ? Headers Headers
  MergeOverride ← (
    ◡Assert!⊓(Struct!Headers|Struct!Headers)
    ◇∧◇Set ⊃(°⊟|⋅□)
  )

  # Expect a single header with the given name, return its value.
  # Throws an error if there are zero more headers with the given name.
  # Value ? HeaderName Headers
  ExpectOne ← (
    ◡⊓(Assert!String|Assert!Struct!Headers)
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
┌─╴RawRequestHeader
  ~ {
    Method: Assert!String
    Path: Assert!String
    Headers: Assert!Struct!Headers
  }

  # Dump the request header to a string.
  # String ? RawRequestHeader
  Dump ← (
    ⊸Assert!Struct!RawRequestHeader
    $"_\r\n_" ⊃($"_ _ HTTP/1.1" ⊃Method Path|Headers~Dump Headers)
  )
└─╴

# Represents an HTTP response header parsed from a raw byte stream,
# without any validation, normalization, or path decoding applied.
┌─╴RawResponseHeader
  ~ {
    StatusCode: IsStatusCode
    Headers: Assert!Struct!Headers
  }

  # Dump the response header to a string.
  # String ? RawResponseHeader
  Dump ← (
    ⊸Assert!Struct!RawResponseHeader
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
┌─╴RawRequest
  ~ {
    RawRequestHeader: Assert!Struct!RawRequestHeader
    Body: Assert!ByteArray
  }

  # Dump HTTP request to a byte array suitable for sending over a network.
  # ByteArray ? Struct!RawRequest
  ToBytes ← (
    ⊸Assert!Struct!RawRequest
    ⊂⊃(utf₈ ˜⊂ "\r\n\r\n" RawRequestHeader~Dump RawRequestHeader|Body)
  )

  # Debug dump the request to a string, with the body truncated if it's not valid UTF-8.
  # String ? Struct!RawRequest
  DebugDump ← (
    ⊸Assert!Struct!RawRequest
    ⊂⊃(˜⊂ "\r\n\r\n" RawRequestHeader~Dump RawRequestHeader|⍣(°utf₈|"[binary data]") Body)
  )
└─╴

# Represents a raw HTTP response parsed from a byte stream, without any validation, normalization.
┌─╴RawResponse
  ~ {
    RawResponseHeader: Assert!Struct!RawResponseHeader
    Body: Assert!ByteArray
  }

  # Dump HTTP response to a byte array suitable for sending over a network.
  # ByteArray ? Struct!RawResponse
  ToBytes ← (
    ⊸Assert!Struct!RawResponse
    ⊂⊃(utf₈ ˜⊂ "\r\n\r\n" RawResponseHeader~Dump RawResponseHeader|Body)
  )

  # Debug dump the response to a string, with the body truncated if it's not valid UTF-8.
  # String ? Struct!RawResponse
  DebugDump ← (
    ⊸Assert!Struct!RawResponse
    ⊂⊃(˜⊂ "\r\n\r\n" RawResponseHeader~Dump RawResponseHeader|⍣(°utf₈|"[binary data]") Body)
  )
└─╴

# Represents a request that has been validated and normalized, ready to be handled by the application.
┌─╴Request
  ~ {
    Method: Assert!String
    Host: Assert!String
    Path: Assert!String
    Query: Assert!String
    Headers: Assert!Struct!Headers
    Body: Assert!ByteArray
  }

  # Convert a raw request to a structured request, validating the method, host, path, and headers.
  # Request ? Struct!RawRequest
  FromRawRequest ← (
    ExtractNormalizedMethod ← (
      ValidMethods ← {"GET" "HEAD" "POST" "PUT" "DELETE" "CONNECT" "OPTIONS" "TRACE" "PATCH"}
      RawRequest~RawRequestHeader≈Method
      ⟜(⍤$"Unrecognized method: _" ⟜(∊ValidMethods □)) ⌵
    )
    ExtractHost ← Headers~ExpectOne "Host" RawRequest~RawRequestHeader≈Headers
    # FIXME: Decode query
    ExtractPathAndQuery ← ⍣(°$"_?_"|⊙⋅"") RawRequest~RawRequestHeader≈Path
    ExtractHeaders ← RawRequest~RawRequestHeader≈Headers
    ExtractBody ← RawRequest~Body
  
    ⊸Assert!Struct!RawRequest
    ⊃(ExtractNormalizedMethod|ExtractHost|ExtractPathAndQuery|ExtractHeaders|ExtractBody)
    Request
  )

  # Get computed headers that will be sent in the request.
  # Headers ? Struct!Request
  GetComputedHeaders ← (
    ⊸Assert!Struct!Request
    ⊙Headers~Default
    ⟜(⨬(◌|Headers~Set "Content-Length") ⊸>₀⧻Body)
    Headers~Set "Host" Host
  )

  # Convert a structured request to a raw request for sending over a network.
  # RawRequest ? Struct!Request
  ToRawRequest ← (
    FormatPath ← ⊂⊃(Path|⍥(⊂@?) ⊸(>₀⧻) Query)
  
    ⊸Assert!Struct!Request
    Request!⊃(RawRequestHeader ⊃(Method|FormatPath|Headers~MergeOverride ⊸GetComputedHeaders Headers)|Body)
    RawRequest
  )
└─╴

┌─╴Response
  ~ {
    StatusCode: IsStatusCode
    Headers: Assert!Struct!Headers
    Body: Assert!ByteArray
  }

  # Convert a raw response to a structured response, validating the status code and headers.
  # Response ? Struct!RawResponse
  FromRawResponse ← (
    ExtractStatusCode ← RawResponse~RawResponseHeader≈StatusCode
    ExtractHeaders ← RawResponse~RawResponseHeader≈Headers
    ExtractBody ← RawResponse~Body
  
    ⊸Assert!Struct!RawResponse
    ⊃(ExtractStatusCode|ExtractHeaders|ExtractBody)
    Response
  )

  # Get computed headers that will be sent in the response.
  # Headers ? Struct!Response
  GetComputedHeaders ← (
    ⊸Assert!Struct!Response
    ⊙Headers~Default
    ⨬(◌|Headers~Set "Content-Length") ⊸>₀⧻Body
  )

  # Convert a structured response to a raw response for sending over a network.
  # RawResponse ? Struct!Response
  ToRawResponse ← (
    ⊸Assert!Struct!Response
    Response!⊃(StatusCode|Headers~MergeOverride ⊸GetComputedHeaders Headers|Body)
    RawResponse RawResponseHeader
  )
└─╴

# Parses an HTTP request from a byte stream.
# Will throw an error if the request is malformed.
# HttpRequest ? StreamHandle
ParseRequestFromStream ← (
  # RawRequestHeader ? String
  ParseRequestHeader ← (
    ⊸Assert!String
    °⊂ °/$"_\r\n_"
    ⊓(⊙⊙◌ °$"_ _ _"|Headers~FromStringLines)
    RawRequestHeader
  )

  ⊸Assert!StreamHandle
  ParseRequestHeader ↘¯4 ⊸&ru "\r\n\r\n"
  RawRequest ⟜(
    RawRequestHeader~Headers
    BodyReadingStrategy~FromHeadersAndStream
  )
  Request~FromRawRequest
)

# Parses an HTTP response from a byte stream.
# Will throw an error if the response is malformed.
# RawResponse ? StreamHandle
ParseResponseFromStream ← (
  # RawResponseHeader ? String
  ParseResponseHeader ← (
    ⊸Assert!String
    °⊂ °/$"_\r\n_"
    ⊓(⍣(◇⋕⊡₁ ◇°/$"_ _"|⍤"Failed to parse status code"0)
    | Headers~FromStringLines)
    RawResponseHeader
  )

  ⊸Assert!StreamHandle
  ParseResponseHeader ↘¯4 ⊸&ru "\r\n\r\n"
  RawResponse ⟜(
    RawResponseHeader~Headers
    BodyReadingStrategy~FromHeadersAndStream
  )
  Response~FromRawResponse
)
