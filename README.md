# Pentoslime

Warning: untested with liveview > 17.5, pretty shure 18 breaks it.

Example of using Slime (http://slime-lang.com/reference/) with Phoenix Liveview

A more extensive reference (for slim, slime's ruby mother) https://rubydoc.info/gems/slim

Uses the good work of Jonathan Yankovich (https://github.com/tensiondriven/phoenix_slime.git)
, who added the heex support to slime for liveview.

Unfortunately the pull request seems to have stalled: https://github.com/slime-lang/slime/pull/168


In mix.exs 

``` elixir
      # {:phoenix_slime, github: "tensiondriven/phoenix_slime"},
      {:phoenix_slime, github: "simonallfrey/phoenix_slime"},
```

This version provides a sigil_H/2 which takes slime and returns a Heex template
(Thank you @thepeoplesbourgouis)

I forked tensiondriven/phoenix_slime just to to hack deps/phoenix_slime/mix.exs
``` elixir
-      {:phoenix_live_view, "> 0.18.0"},
+      {:phoenix_live_view, "> 0.17.0"},
```

lib/pentoslime_web.ex

``` elixir
  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView and .heex helpers (live_render, live_patch, <.form>, etc)
-     import Phoenix.LiveView.Helpers
+     import Phoenix.LiveView.Helpers, except: [sigil_H: 2]
+     import PhoenixSlime, only: [sigil_H: 2]


      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import PentoslimeWeb.ErrorHelpers
      import PentoslimeWeb.Gettext
      alias PentoslimeWeb.Router.Helpers, as: Routes
    end
  end
```


lib/pentoslime_web/live/wrong_live.ex

``` elixir
- use Phoenix.LiveView, layout: {PentoWeb.LayoutView, "live.html"}
+ use PentoslimeWeb, :live_view
```

config/config.exs

``` elixir
config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine,
  #slimleex: PhoenixSlime.LiveViewEngine # If you want to use LiveView
  sheex: PhoenixSlime.LiveViewHTMLEngine
```

## Deployment, Releases and Docker.
https://hexdocs.pm/phoenix/deployment.html
https://hexdocs.pm/phoenix/releases.html

https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach

TLDR: Use --network="host" in your docker run command, then 127.0.0.1 in your docker container will point to your docker host. Note: This mode only works on Docker for Linux, per the documentation.

Build the release and run the server (available on :4000 normally)
``` sh
mix phx.gen.secret
export SECRET_KEY_BASE=6DR+3g8zNX2xNgW/8Wr/aSaekvBY3L7miXdN7ueFmOokqUYTKnTB5F+defE+ZcCN export DATABASE_URL=ecto://postgres:postgres@localhost/pentoslime_dev
export DATABASE_URL=ecto://postgres:postgres@localhost/pentoslime_dev
mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
mix phx.gen.release
MIX_ENV=prod mix release
_build/prod/rel/pentoslime/bin/server
```

Generate Dockerfile
``` sh
mix phx.gen.release --docker
sudo docker build -t pentoslime-docker .
sudo docker run --network="host" -e SECRET_KEY_BASE=6DR+3g8zNX2xNgW/8Wr/aSaekvBY3L7miXdN7ueFmOokqUYTKnTB5F+defE+ZcCN -e DATABASE_URL=ecto://postgres:postgres@127.0.0.1/pentoslime_dev pentoslime-docker
```
Note that any local hacks made in deps will not be included as docker builds the app
from scratch. This is why I had to fork tensiondriven/phoenix_slime and in mix.exs 
``` elixir
-     {:phoenix_slime, github: "tensiondriven/phoenix_slime"},
+     {:phoenix_slime, github: "simonallfrey/phoenix_slime"},
```

## Generic instructions


To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
# programmingPhoenixLiveviewSlime
