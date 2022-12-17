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

## Install docker

``` sh
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo docker run hello-world
# list images
sudo docker images
# get docker network info
docker network ls
docker inspect bridge
docker inspect host
# Maybe need docker-compose later for orchestration with postgres in a container 
sudo apt install docker-compose
```
### Docker hygiene
https://projectatomic.io/blog/2015/07/what-are-docker-none-none-images/

There are good `<none>:<none>` images and there are bad ones.
The good ones are lower layers of a named image. These are only shown
with `docker images -a`.
Any `<nome>:<none>` images shown without the `-a` flag are build artifacts
which need to be removed.

``` sh
$ sudo docker images
REPOSITORY          TAG       IMAGE ID       CREATED         SIZE
pentoslime-docker   latest    f4772d31d503   6 hours ago     126MB
<none>              <none>    1afaa1194230   26 hours ago    126MB
<none>              <none>    6771fb4e6dd1   26 hours ago    1.06GB
<none>              <none>    101c26de854d   26 hours ago    1.06GB
<none>              <none>    425cdc6f490e   26 hours ago    503MB
<none>              <none>    2de8a7c5314e   28 hours ago    198MB
<none>              <none>    3b8586009321   28 hours ago    198MB
elixir              latest    718df5f2725f   9 days ago      1.47GB
postgres            9.6       027ccf656dc1   10 months ago   200MB
# we can clean up with:
$ sudo docker rmi $(sudo docker images -f "dangling=true" -q)
# or maybe be more insistent if claims usage by non existent container.
$ sudo docker rmi -f $(sudo docker images -f "dangling=true" -q)
$ sudo docker images
REPOSITORY          TAG       IMAGE ID       CREATED         SIZE
pentoslime-docker   latest    f4772d31d503   6 hours ago     126MB
elixir              latest    718df5f2725f   9 days ago      1.47GB
postgres            9.6       027ccf656dc1   10 months ago   200MB
#much better
$ sudo docker system df
Images          3         3         1.791GB   0B (0%)
Containers      39        0         326.1MB   326.1MB (100%)
Local Volumes   0         0         0B        0B
Build Cache     0         0         0B        0B
$ sudo du -sh /var/lib/docker
3.8G	/var/lib/docker
```
### Docker resourse usage
https://phoenixnap.com/kb/docker-memory-and-cpu-limit
  
### Setup postgres and ufw for docker
`docker inspect bridge` show us that the docker network is `172.17.0.0/16` 

To get postgresql to accept connections from this network we need to edit `/etc/postgresql/15/main/pg_hba.conf`. It's protected so needs to be opened as root. Open in emacs with `/sudo::/etc/postgresql/15/main/pg_hba.conf`
(you'll be prompted for a password on typing the second colon). Add the last line here.
``` sh
# IPv4 local connections:
host    all             all             127.0.0.1/32            scram-sha-256
host    all             all             172.17.0.0/16           trust
```
We'll also need to add an exception in the firewall, then restart postgres
``` sh
sudo ufw allow in from 172.17.0.0/16
sudo service postgresql restart
```




## Deployment, Releases and docker.
https://hexdocs.pm/phoenix/deployment.html
https://hexdocs.pm/phoenix/releases.html

https://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach

TLDR: Use --network="host" in your docker run command, then 127.0.0.1 in your docker container will point to your docker host. Note: This mode only works on Docker for Linux, per the documentation.

Build the release and run the server (available on :4000 normally)
``` sh
#mix deps.get --only prod
# Docs say --only prod
# I had to do a full deps.get to avoid missing deps with mix phx.gen.release
#mix deps.get --only prod
MIX_ENV=prod mix compile
MIX_ENV=prod mix assets.deploy
# mix phx.gen.release
mix phx.gen.release --docker
MIX_ENV=prod mix release
mix phx.gen.secret
export SECRET_KEY_BASE=6DR+3g8zNX2xNgW/8Wr/aSaekvBY3L7miXdN7ueFmOokqUYTKnTB5F+defE+ZcCN export DATABASE_URL=ecto://postgres:postgres@localhost/pentoslime_dev
_build/prod/rel/pentoslime/bin/server
```
If `DATABASE_URL` or `SECRET_KEY_BASE` is not set we'll get e.g.

``` sh
$ _build/prod/rel/pentoslime/bin/server
ERROR! Config provider Config.Reader failed with:
{"init terminating in do_boot",{#{'__exception__'=>true,'__struct__'=>'Elixir.RuntimeError',message=><<101,110,118,105,114,111,110,109,101,110,116,32,118,97,114,105,97,98,108,101,32,68,65,84,65,66,65,83,69,95,85,82,76,32,105,115,32,109,105,115,115,105,110,103,46,10,70,111,114,32,101,120,97,109,112,108,101,58,32,101,99,116,111,58,47,47,85,83,69,82,58,80,65,83,83,64,72,79,83,84,47,68,65,84,65,66,65,83,69,10>>},....}
...
```
Unfortunately the message is written out as a binary. Dumping it in Iex we get:

``` elixir
ex> <<101,110,118,105,114,111,110,109,101,110,116,32,118,97,114,105,97,98,108,101,32,68,65,84,65,66,65,83,69,95,85,82,76,32,105,115,32,109,105,115,115,105,110,103,46,10,70,111,114,32,101,120,97,109,112,108,101,58,32,101,99,116,111,58,47,47,85,83,69,82,58,80,65,83,83,64,72,79,83,84,47,68,65,84,65,66,65,83,69,10>>
"environment variable DATABASE_URL is missing.\nFor example: ecto://USER:PASS@HOST/DATABASE\n"
ex> <<101,110,118,105,114,111,110,109,101,110,116,32,118,97,114,105,97,98,108,101,32,83,69,67,82,69,84,95,75,69,89,95,66,65,83,69,32,105,115,32,109,105,115,115,105,110,103,46,10,89,111,117,32,99,97,110,32,103,101,110,101,114,97,116,101,32,111,110,101,32,98,121,32,99,97,108,108,105,110,103,58,32,109,105,120,32,112,104,120,46,103,101,110,46,115,101,99,114,101,116,10>>
"environment variable SECRET_KEY_BASE is missing.\nYou can generate one by calling: mix phx.gen.secret\n"

```


Use generated Dockerfile to buid then run in docker
``` sh
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
