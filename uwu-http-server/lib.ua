Assert ~ "../uwu-assert/lib.ua"
Http ~ "../uwu-http/lib.ua"
Errors ~ "./errors.ua"

MimeTypesMap ← comptime(
  &fras $"_/resources/mime\_types.csv" ThisFileDir
  ⊙(map {} {}) °csv
  ∧◇(insert °⊟)
)

# Get the MIME type for a given file extension.
# Throws an error if the extension's MIME type is not known.
# String ? String
GetMimeTypeByExtension ← °□ get ⊃(□|MimeTypesMap)

# Handle an incoming HTTP connection.
# Takes a stream handle and processes the request.
# ? (Strict!Http~Response ? Struct!Http~Request) StreamHandle
HandleConnection! ↚ ⍣(
  # TODO: Run in a loop, handle multiple requests per connection
  # Might have to propose a function to check if a stream is closed.

  ⊸Assert!StreamHandle
  ⊸Http~ParseRequestFromStream
  ⍣(^|˜Errors~RespondInternalServerError)
  ⍣(⍩Errors~RespondInternalServerError "Request was not handled" ⊸Assert!Struct!Http~Request|∘)
  ⊸Assert!Struct!Http~Response
  &cl ⊸&w Http~RawResponse~ToBytes Http~Response~ToRawResponse
| &p $"Error: _" &cl)

# Start a HTTP server on the given [HostPort] (string in the format "hostaddress:portnumber").
# Takes a function that receives a Request and expects a Response.
# 
# `? (Strict!Http~Response ? Struct!Http~Request) HostPort:String`
Serve! ← (
  ⊸Assert!String
  ⍢(◌poolHandleConnection!^ &tcpa|1) &tcpl
)
