uwu (_universal web utility_) - is a [Uiua](https://uiua.org/) framework for web applications.

> [!WARNING]  
> this project is heavily work in progress, heavily uses experimental Uiua features which may break with future updates. not recommended for any serious use. unless you want to seriously have fun.

## features

uwu is the most feature rich implementation of a web framework in Uiua.

- HTTP server
  - message encoding/decoding
  - request/response builder DSL
  - static file serving
  - built in error pages
  - hot reloading
  - idiomatic interface
- HTML builder DSL
  - strings are escaped by default
  - special function to insert unescaped content
  - idiomatic usage, inspired by [webua](https://github.com/uiua-lang/webua)
- type assertion
  - make sure function inputs and struct fields make sense
  - fail early to catch errors faster

## prerequisites

this project uses experimental and cutting-edge Uiua features, which may not even be available in the latest release yet. run `uiua update --main` to build uiua from the latest commit for the best chance to work.

if you want hot-reloading, you will need to install [nodemon](https://nodemon.io/). see the section for [setting up a dev environment](#setting-up-a-dev-environment)

## usage

this is what the code for a basic web app looks like:

```uiua
HttpServer ~ "../uwu-http-server/lib.ua"
Http ~ "../uwu-http/lib.ua"
~ "../uwu-html/lib.ua" ~ Html

HandleIndex ← Http~ResponseOk Html!(ToString Html {
  Head {
    Title "uwu demo"
  }
  Body {
    P $ Hello, world!
  }
})

# The address to bind the server to.
"0.0.0.0:8000"
HttpServer~Serve!(
  # This macro takes a Http~Request and should produce a Http~Response.

  Http~Request!⍣(
    # Define a route for the index page and how to handle it
    ⍩HandleIndex °"/" Path
  | # Serve static files from a "public" directory, relative to this file (optional)
    HttpServer~ServeStatic $"_/_" ThisFileDir "/public"
  | # Show an error when no route matches
    HttpServer~Errors~RespondPageNotFound
  )
)
```

run the file as a standard Uiua application and visit http://localhost:8000 to see the website.

for a more complex example, see [`example/main.ua`](example/main.ua).

## setting up a dev environment

running the entrypoint file as a Uiua application is enough to make it work, but it's more fun to see changes fast. here's how to set up hot-reloading:

1. install [nodemon](https://nodemon.io/)
2. run the command `ENV=dev nodemon --exec "uiua run --no-format" example/main.ua`
    - it should be run from the top most directory of your project, to make sure it watches for any file changes
    - `ENV=dev` enables the server insterting a hot-reload script before the `</head>` declaration and adds a special endpoint to make it work
    - if your editor has auto-save enabled, the server will restart often and constant reformats will make editing code really hard, so I recommend keeping the `--no-format` flag and formatting manually
3. try editing your app and see it change automatically

