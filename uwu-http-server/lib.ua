Assert ~ "../uwu-assert/lib.ua"
Http ~ "../uwu-http/lib.ua"
~ "../uwu-html/lib.ua" ~ Html
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

HandleConnection! ← ⍣(
  # TODO: Run in a loop, handle multiple requests per connection
  # Might have to propose a function to check if a stream is closed.

  ⊸Assert!StreamHandle
  ⊸Http~ParseRequestFromStream
  ⍣(^|˜Errors~RespondInternalServerError)
  ⍣(⍩Errors~RespondInternalServerError "Request was not handled" ⊸Assert!Struct!Http~Request|∘)
  ⊸Assert!Struct!Http~Response
  &cl ⊸&w Http~RawResponse~ToBytes Http~Response~ToRawResponse
| &p $"Error: _" &cl)

Serve! ← ⍢(◌poolHandleConnection!^ &tcpa|1) &tcpl
