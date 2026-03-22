Assert ~ "../uwu-assert/lib.ua"
Http ~ "../uwu-http/lib.ua"
Errors ~ "./errors.ua"
HotReload ~ "./hot-reload.ua"
~ "../uwu-utils/lib.ua" ~ Fs

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
  ⊸Http.ParseRequestFromStream

  # Dispatch the request to the the handler to get a response
  ⍣(HotReload.BuildVersionEndpoint      # The hot reload endpoint only works with ENV=dev environment variable
  | ^                                   # Then try the user-defined handler
  | ⍩˜Errors.RespondInternalServerError # If the handler throws an error, return a 500 status with a message
  )

  # Check that a response was returned
  ⍣(⍩Errors.RespondInternalServerError "Request was not handled" ⊸Assert!Struct!Http.Request|∘)
  ⍣(⊸Assert!Struct!Http.Response|⍩Errors.RespondInternalServerError $"Something other than a response was produced: _")

  # In ENV=dev, attempt to insert the hot reload script into the response
  HotReload.InsertScript
  &cl ⊸&w Http.RawResponse.ToBytes Http.Response.ToRawResponse
| &p $"Error: _" &cl)

# Start a HTTP server on the given [HostPort] (string in the format "hostaddress:portnumber").
# Takes a function that receives a Request and expects a Response.
#
# `? (Struct!Http~Response ? Struct!Http~Request) HostPort:String`
Serve! ← (
  ⊸Assert!String
  ⍢(◌poolHandleConnection!^ &tcpa|1) &tcpl
)

ServeStatic ← (
  ◡⊓(Assert!String|Assert!Struct!Http.Request)
  ⟜(Fs.NormalizePath ⊂) ˜⊂@/ ∩Fs.NormalizePath ⊙Http.Request.Path
  # Ensure the path is within the static directory
  ⊸⍣(°1⊢⌕|⍤⊙0"Request path tried to escape the directory")
  Http.ResponseOk &frab
)
