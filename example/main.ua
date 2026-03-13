# Experimental!

Assert ~ "../uwu-assert/lib.ua"
HttpServer ~ "../uwu-http-server/lib.ua"
Http ~ "../uwu-http/lib.ua"
~ "../uwu-html/lib.ua" ~ Html

RenderLayout ← Html!(ToString Html {
  Head {
    Title "uwu demo"
    Meta!(°⊸Charset "UTF-8")
    Meta!(°⊸Name "viewport" °⊸Content "width=device-width, initial-scale=1.0")
    Script!(°⊸Src "https://cdn.tailwindcss.com") ""
  }
  Body!(°⊸Class "bg-gray-100") {
    Main!(°⊸Class "max-w-7xl mx-auto py-6 sm:px-6 lg:px-8 px-4") {
      Nav {
        Div {
          Div!(°⊸Class "flex items-center justify-between h-16") {
            Div!(°⊸Class "flex items-center") {
              Div!(°⊸Class "flex-shrink-0") {
                H₁!(°⊸Class "text-xl font-bold") "uwu demo"
              }
              Div!(°⊸Class "ml-10 flex items-baseline space-x-4") {
                Link ← A!(°⊸Class "text-blue-500 hover:text-blue-700 hover:underline" °⊸Href)
                Link "/" "Home"
                Link "/raw" "Raw HTML"
                Link "/form" "Form"
                Link "/images" "Images"
                Link "/error?key=value&something=else&list[]=1&list[]=2" "Error"
                Link "/non-existant-page" "404"
              }
            }
          }
        }
      }
      Div ∘ # Page content goes here
    }
  }
})

HandleIndex ← Http~ResponseOk RenderLayout ⋅Html!{
  P "Welcome to the uwu demo! This is the home page."
}

HandleRawHtml ← Http~ResponseOk RenderLayout ⋅Html!{
  P $ Heres some raw HTML: <script>alert("unsafe input")</script>. It's escaped without any special handling.
  Br
  P UnsafeRawText $ This is some raw HTML that is not escaped: <strong>bold text</strong> and <em>italic text</em>. Use <code class="bg-gray-200">UnsafeRawText</code> to include unescaped HTML.
}

┌─╴FormErrors
  ~ {Messages: Assert!List!String}

  Default ← New {}

  HasErrors ← (
    ⊸Assert!Struct!FormErrors
    >0⧻ Messages
  )

  Insert ← (
    ◡⊓(Assert!String|Assert!Struct!FormErrors)
    ⍜⊙Messages˜⊂ □
  )
└─╴

┌─╴FormData
  ~ {
    Name: Assert!String
    Message: Assert!String
  }

  Default ← New "" ""

  Validate ← (
    ⊸Assert!Struct!FormData
    ⊙FormErrors~Default
    ⟜⍣(°0 =0⧻ Name|FormErrors~Insert⋅"The name cannot be empty")
    ⟜⍣(°0 >255⧻ Name|FormErrors~Insert⋅"The name cannot be longer than 255 characters")
    ⟜⍣(°0 =0⧻ Message|FormErrors~Insert⋅"The message cannot be empty")
    ⟜⍣(°0 >1000⧻ Message|FormErrors~Insert⋅"The message cannot be longer than 1000 characters")
    ◌
  )

  FromRequest ← (
    ⊸Assert!Struct!Http~Request
    Http~Request~BodyAsForm
    New ⊃(
      ⬚""Http~QueryValues~GetOne "name"
    | ⬚""Http~QueryValues~GetOne "message"
    )
  )
└─╴

~Form {FormData FormErrors} ⬚∘Html!{
  H₁!(°⊸Class "text-2xl font-bold") "Contact us"
  (
    ⊸FormErrors≈HasErrors °◌
    ⨬(""|Div!(°⊸Class "mt-4 bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative") {
      Ul!(°⊸Class "list-disc list-inside") (⍚Li FormErrors≈Messages)
    })
  )
  Form!(°⊸Method "POST" °⊸Action "/form" °⊸Class "mt-4 space-y-4") {
    Div!(°⊸Class "space-y-1") {
      Label!(°⊸For "name" °⊸Class "block text-sm font-medium text-gray-700") "Name"
      Input!(°⊸Type "text" °⊸Name "name" °⊸Id "name" °⊸Class "shadow-sm focus:ring-blue-500 focus:border-blue-500 block w-full sm:text-sm border-gray-300 rounded-md p-2" °⊸Value (FormData≈Name °◌))
    }
    Div!(°⊸Class "space-y-1") {
      Label!(°⊸For "message" °⊸Class "block text-sm font-medium text-gray-700") "Message"
      Textarea!(°⊸Name "message" °⊸Id "message" °⊸Class "shadow-sm focus:ring-blue-500 focus:border-blue-500 block w-full sm:text-sm border-gray-300 rounded-md p-2") (FormData≈Message°◌)
    }
    Button!(°⊸Type "submit" °⊸Class "bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded") "Submit"
  }
}

HandleFormGet ← ⋅(
  FormData~Default FormErrors~Default
  Http~ResponseOk RenderLayout Form
)

HandleFormPost ← (
  ⊸FormData~Validate FormData~FromRequest
  ⊸FormErrors~HasErrors
  ⨬($"Submitted form data: _" ⋅repr
    Html~Div!(°⊸Class "mt-4 bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded relative")
    Http~ResponseOk RenderLayout
  | Http~ResponseBadRequest RenderLayout ˜Form
  )
)

HandleImages ← Http~ResponseOk RenderLayout⋅Html!({
  P "Here are some static images served from the /public directory:"
  Div!(°⊸Class "grid grid-cols-1 sm:grid-cols-2 md:grid-cols-2 gap-4 mt-4") {
    Img!(°⊸Src "/uwu.gif" °⊸Alt "uwu" °⊸Class "w-full h-auto")
    Img!(°⊸Src "/kala.png" °⊸Alt "Kala - the Uiua mascot" °⊸Class "w-full h-auto")
  }
})

"0.0.0.0:8000"
HttpServer~Serve!(
  Http~Request!⍣(
    ⍩HandleIndex ⊸(°"/" Path)
  | ⍩HandleRawHtml ⊸(°"/raw" Path)
  | ⍩HandleFormGet ⊸⊃(°"GET" Method|°"/form" Path)
  | ⍩HandleFormPost ⊸⊃(°"POST" Method|°"/form" Path)
  | ⍩HandleImages ⊸(°"/images" Path)
  | ⍩(⍤⊙0 "Something went wrong [intentionally!]") ⊸(°"/error" Path)
  | HttpServer~ServeStatic $"_/_" ThisFileDir "/public"
  | HttpServer~Errors~RespondPageNotFound
  )
)
