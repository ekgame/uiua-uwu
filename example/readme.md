# Example website

## Running the server

Starting the server is as easy as running a normal Uiua application.

1. Make sure you have the latest version of Uiua, built directly from the last commit. This project uses experimental features that may not be available in the latest release. Run `uiua update --main` to build from git.
2. Run `uiua run example/main.ua` from the root directory of the project.
3. Open http://localhost:8000/ to see the website.

## Running a dev server with hot-reload

1. Make sure you have Node.js installed on your system.
2. Run `npm install -g nodemon` to install nodemon.
3. Run `ENV=dev nodemon --exec "uiua run --no-format" example/main.ua` to start the server with nodemon. It will detect changes in the project files and restart the server.
4. Open http://localhost:8000/ to see the website. Any changes to the code should be reflected in a couple of seconds.

The `ENV=dev` declatarion will enable hot-reloading, to reload the current page after the server is restarted. Hot reloading automatically adds a new route and inserts a script before the `</head>` declaration.