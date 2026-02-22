Http ~ "lib.ua"
~ "../uwu-utils/lib.ua" ~ Strings

# --- Header unit tests ---

Http~Headers!(
  Default
  Add "A" "Foo"
  Add "A" "Bar"
  Add "B" "Baz"
)
˙⍤≍ {{"A" "A" "B"} {"Foo" "Bar" "Baz"}}

Http~Headers!(
  Default
  Set "A" "Foo"
  Set "A" "Bar"
)
˙⍤≍ {{"A"} {"Bar"}}

Http~Headers!(
  Default
  Add "A" "Foo"
  Add "B" "Bar"

  Default
  Add "B" "Baz"
  Add "C" "Qux"

  MergeOverride
)
˙⍤≍ {{"A" "B" "C"} {"Foo" "Baz" "Qux"}}

# --- Request parsing tests ---

StringAsStream ↚ (
  ⍣(°$"_\n\n_"|⊙"")
  /$"_\r\n_" °/$"_\n_"
  $"_\r\n\r\n_"
  &fo "test" ⍜(&fc "test"|˜&w)
)

$ GET /hello/world?foo=bar HTTP/1.1
$ Host: example.com
StringAsStream
Http~ParseRequestFromStream
Http~Request!⊃(
  ˙⍤≍ "GET" Method
| ˙⍤≍ "example.com" Host
| ˙⍤≍ "/hello/world" Path
| ˙⍤≍ "foo=bar" Query
| ˙⍤≍ {{"Host"} {"example.com"}} Headers
| ˙⍤≍ [] Body
)

$ POST /foo/bar HTTP/1.1
$ Host: example.com
$ Content-Length: 13
$ 
$ Hello, world!
Http~ParseRequestFromStream StringAsStream
Http~Request!⊃(
  ˙⍤≍ "POST" Method
| ˙⍤≍ "example.com" Host
| ˙⍤≍ "/foo/bar" Path
| ˙⍤≍ "" Query
| ˙⍤≍ {{"Host" "Content-Length"} {"example.com" "13"}} Headers
| ˙⍤≍ utf₈"Hello, world!" Body
)

# --- Response parsing tests ---

$ HTTP/1.1 204 No Content
$ 
Http~ParseResponseFromStream StringAsStream
Http~Response!⊃(
  ˙⍤≍ 204 StatusCode
| ˙⍤≍ {{} {}} Headers
| ˙⍤≍ [] Body
)

$ HTTP/1.1 200 OK
$ Content-Length: 5
$ 
$ Hello
Http~ParseResponseFromStream StringAsStream
Http~Response!⊃(
  ˙⍤≍ 200 StatusCode
| ˙⍤≍ {{"Content-Length"} {"5"}} Headers
| ˙⍤≍ utf₈"Hello" Body
)

# --- Request building tests ---

RequestToString ← Http!(
  Request~ToRawRequest
  °utf₈ RawRequest~ToBytes
  Strings~Replace "\r\n" "\n"
)

Http~BuildRequest!(
  Method "GET"
  Url "http://example.com/hello/world?foo=bar"
)
RequestToString
$ GET /hello/world?foo=bar HTTP/1.1
$ Host: example.com
$ 
$ 
˙⍤≍

Http~BuildRequest!(
  Method "GET"
  Host "example.com"
  Path "/hello/world"
  Query "foo=bar"
  Body "Hello, world!"
  AddHeader "Custom-Header" "CustomValue"
  AddHeader "Content-Length" "1111"
)
RequestToString
$ GET /hello/world?foo=bar HTTP/1.1
$ Custom-Header: CustomValue
$ Content-Length: 13
$ Host: example.com
$ 
$ Hello, world!
˙⍤≍

# --- Response building tests ---

ResponseToString ← Http!(
  Response~ToRawResponse
  °utf₈ RawResponse~ToBytes
  Strings~Replace "\r\n" "\n"
)

Http~BuildResponse!(
  StatusCode 200
  Body "Hello, world!"
  AddHeader "Content-Type" "text/plain"
)
ResponseToString
$ HTTP/1.1 200
$ Content-Type: text/plain
$ Content-Length: 13
$ 
$ Hello, world!
˙⍤≍

Http~BuildResponse!(
  StatusCode 204
)
ResponseToString
$ HTTP/1.1 204
$ 
$ 
˙⍤≍

# --- Response shortcut tests ---

Http~ResponseOk "Hello, world!"
ResponseToString
$ HTTP/1.1 200
$ Content-Length: 13
$ 
$ Hello, world!
˙⍤≍

Http~ResponseOk!(AddHeader "Custom-Header" "CustomValue") "Hello, world!"
ResponseToString
$ HTTP/1.1 200
$ Custom-Header: CustomValue
$ Content-Length: 13
$ 
$ Hello, world!
˙⍤≍
