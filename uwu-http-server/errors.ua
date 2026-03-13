# Experimental!

Http ~ "../uwu-http/lib.ua"
~ "../uwu-html/lib.ua" ~ Html
Assert ~ "../uwu-assert/lib.ua"

Styles ← comptime(&fras $"_/resources/style.css" ThisFileDir)

~ResponseTemplateError {
  Status: Assert!Scalar!Int
  PageTitle: Assert!String
  Message: Assert!String
  Request: Assert!Struct!Http~Request
} ⬚∘Html!(ToString Html {
  Head {
    Title PageTitle °◌
    Meta!(°⊸Charset "UTF-8")
    Meta!(°⊸Name "viewport" °⊸Content "width=device-width, initial-scale=1.0")
    Style Styles
  }

  Body {
    Main {
      Div!(°⊸Class "heading") {
        P ($"HTTP _" Status °◌)
        H₁ (PageTitle °◌)
      }
      Div!(°⊸Class "error-message") {
        P (Message °◌)
      }
      Div!(°⊸Class "request-grid") {
        Span!(°⊸Class "muted") "Request"
        Span ($"_ _" Http~Request!⊃(Method|Path) Request °◌)
      
        (
          ⊸Http~QueryValues~HasValues Http~Request~Query Request °◌
          ⨬(""|{
            Span!(°⊸Class "muted") "Query"
            Span Http~QueryValues!(
              ⍚(Span!(°⊸Class "line") $"_ = _") °Http~QueryValues
            )
          })
        )
      }
    }
  }
})

# Return a HTTP response with the given message as a HTTP 500 Internal Server Error.
# Response ? String Request 
RespondInternalServerError ← (
  ResponseTemplateError 500 "Internal Server Error"
  Http~ResponseInternalServerError
)

# Return a HTTP response with the given message as a HTTP 404 Not Found.
# Response ? Request 
RespondPageNotFound ← (
  ResponseTemplateError 404 "Not Found" "The requested resource was not found on this server."
  Http~ResponseNotFound
)
