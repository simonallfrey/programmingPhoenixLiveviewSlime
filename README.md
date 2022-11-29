# Pentoslime

Example of using Slime (http://slime-lang.com/reference/) with Phoenix Liveview

A more extensive reference (for slim, slime's ruby mother) https://rubydoc.info/gems/slim

Uses the good work of Jonathan Yankovich (https://github.com/tensiondriven/phoenix_slime.git)
Who added the heex support to slime for liveview.

Unfortunately the pull request seems to have stalled: https://github.com/slime-lang/slime/pull/168


In mix.exs 

``` elixir
      {:phoenix_slime, "~> 0.13.0", git: "https://github.com/tensiondriven/phoenix_slime.git"},
```

This version provides a sigil_H/2 which takes slime and returns a Heex template

I had to hack deps/phoenix_slime/mix.exs
``` elixir
-      {:phoenix_live_view, "> 0.18.0"},
+      {:phoenix_live_view, "> 0.17.5"},
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
