# Notes from Programming Phoenix Liveview

## Chapter 3 Generators Contexts and Schemas


``` bash
$ mix phx.gen.live Catalog Product products name:string description:string unit_price:float sku:integer:unique
...
...
    Add the live routes to your browser scope in lib/pentoslime_web/router.ex:

    live "/products", ProductLive.Index, :index
    live "/products/new", ProductLive.Index, :new
    live "/products/:id/edit", ProductLive.Index, :edit

    live "/products/:id", ProductLive.Show, :show
    live "/products/:id/show/edit", ProductLive.Show, :edit


Remember to update your repository by running migrations:

    $ mix ecto.migrate

```
Creates 
 - (a migration for) a database table 'products' with the fields name,description,unit_price and sku
 - a schema 'Product' the core (think ORM without objects)  
   Translates between the products database table and the Pento.Catalog.Product Elixir struct.
 - a context 'Catalog' the boundary (this is our API, deals with uncertainty)
 
We put the routes in the 
``` elixir
    pipe_through [:browser, :require_authenticated_user]
```
scope

Here's where the live actions are generated:
```
  pentoslime/lib/pentoslime_web/live/product_live:
  total used in directory 32K available 643.9 GiB
  -rw-rw-r-- 1 s s 1.6K Nov 29 12:00 form_component.ex
  -rw-rw-r-- 1 s s  683 Nov 29 12:00 form_component.html.heex
  -rw-rw-r-- 1 s s 1.1K Nov 29 12:00 index.ex
  -rw-rw-r-- 1 s s 1.4K Nov 29 12:00 index.html.heex
  -rw-rw-r-- 1 s s  495 Nov 29 12:00 show.ex
  -rw-rw-r-- 1 s s  922 Nov 29 12:00 show.html.heex
```
The ProductLive.Index module is generated in index.ex, ProductLive.Show module in show.ex 

(note the code and the template are generated in the same directory.)

The mirgration is created in:

```
  pentoslime/priv/repo/migrations:
  total used in directory 20K available 643.9 GiB
  -rw-rw-r-- 1 s s   52 Oct 31 23:07 .formatter.exs
  -rw-rw-r-- 1 s s  762 Nov 26 17:26 20221126162604_create_users_auth_tables.exs
  -rw-rw-r-- 1 s s  318 Nov 29 12:00 20221129110046_create_products.exs
  
```
  (note we still have the mirgraion from introducting user authentication, so mix must keep track of which migrations have been applied)
  
  
``` elixir
defmodule Pentoslime.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :description, :string
      add :unit_price, :float
      add :sku, :integer

      timestamps()
    end

    create unique_index(:products, [:sku])
  end
end
```


So now we just
``` bash
$ mix ecto.migrate
```
## The Schema "Product"
Our core interface to the database
```
iex> alias Pento.Catalog.Product
iex> exports Product
__changeset__/0
__schema__/1
__struct__/1
changeset/2
__schema__/2
__struct__/0
When you look at the public functions with exports Product, you can see the
```


Here's what the struct looks like:
```
iex> Product.__struct__
%Pento.Catalog.Product{
__meta__: #Ecto.Schema.Metadata<:built, "products">,
description: nil,
id: nil,
inserted_at: nil,
name: nil,
sku: nil,
unit_price: nil,
updated_at: nil
}
```
We create a new product like this:
```
iex> Product.__struct__(name: "Exploding Ninja Cows")
%Pento.Catalog.Product{
__meta__: #Ecto.Schema.Metadata<:built, "products">,
description: nil,
id: nil,
inserted_at: nil,
name: "Exploding Ninja Cows",
sku: nil,
unit_price: nil,
updated_at: nil
}
```
changeset/2 validates changes, so to insert a new product into the database (repository) you could do:
```
alias Pentoslime.Catalog.Product
empty_product = %Product{}
attrs = %{
name: "Pentominoes",
sku: 123456,
unit_price: 5.00,
description: "A super fun game!"
}
alias Pentoslime.Repo
Product.changeset(empty_product,attrs) |> Repo.insert()
```
If the attrs don't conform the changeset is marked as `valid?: false`

Note that building queries and preparing database transactons are predictable actions and belong in the (core) Schema, here "Product"

Actions with unpredictable outcomes, such as interecting with the (external) database belong in the (boundary) Context, here "Catalog"

Ecto code that deals with the certain and predictable
work of building queries and preparing database transactions belongs in the
core. That is why, for example, we found the changeset code that sets up
database transactions in the Product schema. 

Executing database requests,
on the other hand, is unpredictable—it could always fail. Ecto implements
the Repo module to do this work and any such code that calls on the Repo
module belongs in the context module, our application’s boundary layer.

## The Context "Catalog"

`catalog.ex` containes the CRUD (create read update delete) functions.
```
7 matches for "def" in buffer: catalog.ex
      1:defmodule Pentoslime.Catalog do
     20:  def list_products do
     38:  def get_product!(id), do: Repo.get!(Product, id)
     52:  def create_product(attrs \\ %{}) do
     70:  def update_product(%Product{} = product, attrs) do
     88:  def delete_product(%Product{} = product) do
    101:  def change_product(%Product{} = product, attrs \\ %{}) do
```

`catalog/product.ex` countains our struct and core functions

```
  pentoslime/lib/pentoslime:
  total used in directory 44K available 643.9 GiB
  drwxrwxr-x 2 s s 4.0K Nov 26 17:26 accounts
  drwxrwxr-x 2 s s 4.0K Nov 29 12:00 catalog
  -rw-rw-r-- 1 s s 8.9K Nov 26 17:26 accounts.ex
  -rw-rw-r-- 1 s s 1.1K Oct 31 23:07 application.ex
  -rw-rw-r-- 1 s s 1.8K Nov 29 12:00 catalog.ex
  -rw-rw-r-- 1 s s   77 Oct 31 23:07 mailer.ex
  -rw-rw-r-- 1 s s  112 Oct 31 23:07 repo.ex

  pentoslime/lib/pentoslime/catalog:
  total used in directory 12K available 643.9 GiB
  -rw-rw-r-- 1 s s  472 Nov 29 12:00 product.ex
```
Because actions in the context might fail we can't use straight pipelines.
Elixir has a bulit in monad for this, the `with` construct. e.g.:

``` elixir
defmodule Pento.Catalog do
 alias Catalog.Coupon.Validator
 alias Catalog.Coupon
 defp validate_code(code) do
  Validator.validate_code(code) # will return an :ok, *or* an :error tuple
 end
 defp calculate_new_total(code, purchase_total) do
  Coupon.calculate_new_total(code, purchase_total) # will return an :ok, *or* an :error tuple
 end
 def apply_coupon_code(code, purchase_total) do
  with {:ok, code} <- validate_coupon(code),
    {:ok, new_total} <- calculate_new_total(code, purchase_total) do
    new_total
  else
    {:error, reason} -> IO.puts "Error applying coupon: #{reason}"
    _ -> IO.puts "Unknown error applying coupon."
  end
 end
end
```

If you don't like `with` you might try: https://hexdocs.pm/monad/Monad.html which is showcased at https://zohaib.me/monads-in-elixir-2 .

## Give It a Try
- Create another changeset in the Product schema that only changes the
unit_price field and only allows for a price decrease from the current price.
- Then, create a context function called markdown_product/2 that takes in an
argument of the product and the amount by which the price should
decrease. This function should use the new changeset you created to
update the product with the newly decreased price.

``` elixir
@doc """
Reduces the :unit_price of a product with an existing :unit_price

Catch case product.unit_price=nil as cannot validate less_than: nil

Error message doesn't clarify that it's the original :unit_price
which can't be nil...

#Ecto.Changeset<
  action: nil,
  changes: %{},
  errors: [unit_price: {"can't be blank", [validation: :required]}],
  data: #Pentoslime.Catalog.Product<>,
  valid?: false
>
"""
def reduce_unit_price(product, _attrs) when product.unit_price = nil do
  product
  |> cast(%{}, [])
  |> validate_required([:unit_price])
end
def reduce_unit_price(%{unit_price: oldprice}=product,attrs)
  product
  |> cast(attrs, [:unit_price])
  |> validate_number(:unit_price, less_than: oldprice)
end

@doc """
Reduces the :unit_price of a product with an existing :unit_price

Catch case product.unit_price=nil as cannot validate less_than: nil

Error message specifies it's the original :unit_price which can't be nil.

{:error, "require product.unit_price != nil"}

(But it's not a changeset...)
"""
# also, pattern matching prefered to guards in simple cases
# https://stackoverflow.com/questions/30589187/elixir-pattern-match-or-guard
def reduce_unit_price_beta(%{unit_price: nil}=product,_attrs) do
  {:error, "require product.unit_price != nil"}
end
def reduce_unit_price(%{unit_price: oldprice}=product,attrs)
  product
  |> cast(attrs, [:unit_price])
  |> validate_number(:unit_price, less_than: oldprice)
end
```

## Generators: Live Views and Templates
- insert mode Ctrl-r % to insert the name of the current file.
- markdown inline code is surrounded by backticks.
- SPACE c d for wordnet dictionary.
- SPACE u for universal prefix
- SPACE p f find file in project 
- SPACE u SPACE p f clear cache and find file in project
- iex interrupt multiline input with Ctrl-g i return c return (or c return to continue)  
  This uses erlang's "User switch command" (don't press Ctrl-g twice or all is lost!)  
  https://stackoverflow.com/questions/41866638/how-can-i-exit-a-multi-line-command-sequence-in-the-erlang-shell
- IEx and IO.Inspect use #PID<...> #Fuction<...> #structname<...> sytax to represent language elements.
- use xargs -I <placeholder> to pipe somewhere other than the end of the command  
  e.g.  
  `locate -i file_i_want_here.txt | head -1 | xargs -I {} cp {} file_here.txt`
- https://stackoverflow.com/questions/22817120/how-can-i-save-evil-mode-vim-style-macros-to-my-init-el




Recall, the routes are defined as

Here `live/4` is a macro, made available with

`pentoslime/lib/pentoslime_web/router.ex`
```elixir
  use PentoslimeWeb, :router
```
This `use` injects the `PentoWeb.router/0` function into the current module.

`pentoslime/lib/pentoslime_web.ex`
```elixir
defmodule PentoslimeWeb do
...
  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end
...
end
```
Finally it is the `import Phoenix.LiveView.Router` that provides the `live/4` macro.

`pentoslime/lib/pentoslime_web/router.ex`
``` elixir
    live "/products", ProductLive.Index, :index
    live "/products/new", ProductLive.Index, :new
    live "/products/:id/edit", ProductLive.Index, :edit
    live "/products/:id", ProductLive.Show, :show 
    live "/products/:id/show/edit", ProductLive.Show, :edit
```
Ties urls to liveview modules e.g. ProductLive.Index, and a "live action" e.g. :new or :edit
Actions let one liveview (module) manage multiple page states.

The atoms in the name represent named parameters, which will be available in the module e.g. %{"id" => "333"}
n.b. the map uses strings (binaries)

The modules were created in e.g. ProductLive.Show

`lib/pentoslime_web/live/product_live/show.ex`
`lib/pentoslime_web/live/product_live/show.html.heex`

3 workflows
- 1st mount: set initial state, push stuff into the socket  .
- 2nd handle_params: (if implemented)
- 3rd render: render it, using the data in the socket's assigns to complete the @variables in the heex template

If we get to the route via `live_patch`(client side) or `push_patch`(server side) only the second two workflows are triggered, we skip the mount.
`push_redirect` (server side) _does_ call mount.
  
`pentoslime/lib/pentoslime_web/live/product_live/index.ex`
```elixir
  def mount(_params, _session, socket) do
    # update socket's assigns with :products => [a list of all the products]
    {:ok, assign(socket, :products, list_products())}
  end
```

When filling out the template we can iterate over the list of products.

`pentoslime/lib/pentoslime_web/live/product_live/index.html.heex`
```heex
...
    <%= for product <- @products do %>
...
```

The action is passed into the socket's assigns as `:live_action => :action`
It is `handle_params` job to deal with it e.g. :


`pentoslime/lib/pentoslime_web/live/product_live/index.ex`
```elixir
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end
  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Product")
    |> assign(:product, Catalog.get_product!(id))
  end
```
We can see what the template does with the new state:

`pentoslime/lib/pentoslime_web/live/product_live/index.html.heex`
```heex
<%= if @live_action in [:new, :edit] do %>
  <.modal return_to={Routes.product_index_path(@socket, :index)}>
    <.live_component
      module={PentoslimeWeb.ProductLive.FormComponent}
      id={@product.id || :new}
      title={@page_title}
      action={@live_action}
      product={@product}
      return_to={Routes.product_index_path(@socket, :index)}
    />
  </.modal>
<% end %>
```
It slaps a modal on top of our view with the editing functionality.

https://hexdocs.pm/phoenix_live_view/Phoenix.LiveComponent.html

live components are stateful, regular phoenix function components are stateless.
A function component takes an assigns map and returns a rendered heex template.
A live component has in id attribute and has event handlers.

A live_component has its own lifecycle: 
- when first created a live_component's `mount` is called
- on state change live component's `update` is called then its `render`

`use PentoslimeWeb :live_component` provides the default versions of these callbacks.
default `mount` just passes the socket unchanged.

Here form_components provides its own `update`
Because an explicit `render/1` is not defined it uses `form_component.html.heex` in the same directory.
We also have a couple of event handlers for "validate" and "save" events associsted with the form's
`phx-change="validate"` and `phx-submit="save"`

`pentoslime/lib/pentoslime_web/live/product_live/form_component.ex`
```elixir
  use PentoslimeWeb, :live_component

  alias Pentoslime.Catalog

  @impl true
  def update(%{product: product} = assigns, socket) do
    changeset = Catalog.change_product(product)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"product" => product_params}, socket) do
    changeset =
      socket.assigns.product
      |> Catalog.change_product(product_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"product" => product_params}, socket) do
    save_product(socket, socket.assigns.action, product_params)
  end

```

`pentoslime/lib/pentoslime_web/live/product_live/form_component.html.heex`
```heex
...
  <.form
    let={f}
    for={@changeset}
    id="product-form"
    phx-target={@myself}
    phx-change="validate"
    phx-submit="save">
  ...
  ...
  </.form>
...
```

The difference between those is mostly the amount of data sent over the wire:

`link/2` and `redirect/2` do full page reloads

`live_redirect/2` and `push_redirect/2` mounts a new LiveView while keeping the current layout

`live_patch/2` and `push_patch/2` updates the current LiveView and sends only the minimal diff while also maintaining the scroll position

An easy rule of thumb is to stick with `live_redirect/2` and `push_redirect/2` and use the patch helpers only in the cases where you want to minimize the amount of data sent when navigating within the same LiveView (for example, if you want to change the sorting of a table while also updating the URL).

## Chapter 6 Function Components

About database indicies:
https://stackoverflow.com/questions/1108/how-does-database-indexing-work


`unique_constraint(changeset, field_or_fields, opts \\ [])`

`@spec unique_constraint(t(), atom() | [atom(), ...], Keyword.t()) :: t()`

Checks for a unique constraint in the given field or list of fields.

The unique constraint works by relying on the database to check if the unique constraint has been violated or not and, if so, Ecto converts it into a changeset error.

In order to use the uniqueness constraint, the first step is to define the unique index in a migration:

`create unique_index(:users, [:email])`

Now that a constraint exists, when modifying users, we could annotate the changeset with a unique constraint so Ecto knows how to convert it into an error message:

```elixir
cast(user, params, [:email])
|> unique_constraint(:email)
```
Now, when invoking `Ecto.Repo.insert/2` or `Ecto.Repo.update/2,` if the email already exists, the underlying operation will fail but Ecto will convert the database exception into a changeset error and return an {:error, changeset} tuple. Note that the error will occur only after hitting the database, so it will not be visible until all other validations pass. If the constraint fails inside a transaction, the transaction will be marked as aborted.


And uniqueness on column pairs:
https://stackoverflow.com/questions/36418223/creating-a-unique-constraint-on-two-columns-together-in-ecto

Using only create unique_index on your model will ultimately throw an exception instead of giving you an error.

To get an error add a constraint on your changeset but as a parameter you can give the index name created by unique_index.

So in your migration file :

```elixir
create unique_index(:your_table, [:col1, :col2], name: :your_index_name)
```

Then in your changeset :

```elixir
def changeset(model, param \\ :empty) do
  model
  |> cast(params, @required_fields, @optional_fields)
  |> unique_constraint(:name_your_constraint, name: :your_index_name)
end
```

n.b. `:name_your_constraint` doesn't need to be `:col1` or `:col2` its only purpose is to apper in the error message
when we are checking a unique index constraint using the name: option. e.g.

```elixir
# lib/pentoslime/survey/rating.ex
#   |> unique_constraint(:user_can_only_give_one_rating_per_product, name: :index_ratings_on_user_product)

pentoslime$ iex -S mix
iex> alias Pentoslime.Accounts
iex> user_attrs = %{email: "s2@j.a", password: "letmeinletmein"}
iex> {:ok, user} = Accounts.register_user(user_attrs)           
{:ok,
 #Pentoslime.Accounts.User<
   __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
   id: 4,
   email: "s2@j.a",
   confirmed_at: nil,
   inserted_at: ~N[2022-12-14 14:35:35],
   updated_at: ~N[2022-12-14 14:35:35],
   ...
 >}
iex> user = "s2@j.a" |> Accounts.get_user_by_email 
iex> Accounts.reset_user_password(user, %{password: "letmeinletmein2", password_confirmation: "letmeinletmein2"})
{:ok,
 #Pentoslime.Accounts.User<
   __meta__: #Ecto.Schema.Metadata<:loaded, "users">,
   id: 4,
   email: "s2@j.a",
   confirmed_at: nil,
   inserted_at: ~N[2022-12-14 14:35:35],
   updated_at: ~N[2023-01-04 13:23:04],
   ...
 >}

iex> alias Pentoslime.Survey
iex> demo_attrs=%{user_id: user.id, gender: "male", year_of_birth: 1973}
iex> Survey.create_demographic(demo_attrs)
{:ok,
 %Pentoslime.Survey.Demographic{
   __meta__: #Ecto.Schema.Metadata<:loaded, "demographics">,
   id: 1,
   gender: "male",
   year_of_birth: 1973,
   user_id: 4,
   user: #Ecto.Association.NotLoaded<association :user is not loaded>,
   inserted_at: ~N[2022-12-14 14:58:19],
   updated_at: ~N[2022-12-14 14:58:19]
 }}
iex> alias Pentoslime.Catalog
iex> Catalog.list_products |> Enum.map(fn x -> x.id end)
'\n\f\r\b\t\v'
iex> Catalog.list_products |> Enum.map(fn x -> x.id end) |> List.to_tuple
{10, 12, 13, 8, 9, 11}
iex> rating_attrs = %{user_id: user.id, product_id: 10, stars: 5}          
%{product_id: 10, stars: 5, user_id: 4}
iex> Survey.create_rating(rating_attrs)                                    
{:ok,
 %Pentoslime.Survey.Rating{
   __meta__: #Ecto.Schema.Metadata<:loaded, "ratings">,
   id: 6,
   stars: 5,
   user_id: 4,
   user: #Ecto.Association.NotLoaded<association :user is not loaded>,
   product_id: 10,
   product: #Ecto.Association.NotLoaded<association :product is not loaded>,
   inserted_at: ~N[2022-12-14 16:03:20],
   updated_at: ~N[2022-12-14 16:03:20]
 }}
iex> Survey.create_rating(rating_attrs)
{:error,
 #Ecto.Changeset<
   action: :insert,
   changes: %{product_id: 10, stars: 5, user_id: 4},
   errors: [user_can_only_give_one_rating_per_product: {"has already been taken", [constraint: :unique, constraint_name: "index_ratings_on_user_product"]}],
   data: #Pentoslime.Survey.Rating<>,
   valid?: false
 >}
iex> r = Survey.get_rating!(6)
%Pentoslime.Survey.Rating{
  __meta__: #Ecto.Schema.Metadata<:loaded, "ratings">,
  id: 6,
  stars: 5,
  user_id: 4,
  user: #Ecto.Association.NotLoaded<association :user is not loaded>,
  product_id: 10,
  product: #Ecto.Association.NotLoaded<association :product is not loaded>,
  inserted_at: ~N[2022-12-14 16:03:20],
  updated_at: ~N[2022-12-14 16:03:20]
}
iex> Survey.update_rating(r,%{rating_attrs| stars: 4})
{:ok,
 %Pentoslime.Survey.Rating{
   __meta__: #Ecto.Schema.Metadata<:loaded, "ratings">,
   id: 6,
   stars: 4,
   user_id: 4,
   user: #Ecto.Association.NotLoaded<association :user is not loaded>,
   product_id: 10,
   product: #Ecto.Association.NotLoaded<association :product is not loaded>,
   inserted_at: ~N[2022-12-14 16:03:20],
   updated_at: ~N[2022-12-14 16:05:34]
 }}

```

### Associations and Preloading queries
p160 of Programming Phoenix Liveview  

See p49 "Adding Associations to Schemas" of the Programming Ecto book.

At the database level, we connect two tables with a foreign key: e.g. artist_id column in
albums refers to the primary key of the artists table. In Ecto, we use associations
to model these relationships. Associations help reflect the connections between
database tables in our Elixir code.

`has_many` is and example of an association.
```elixir
defmodule MusicDB.Album do
  use Ecto.Schema
  schema "albums" do
    field :title, :string
    field :release_date, :date
    has_many :tracks, MusicDB.Track
  end
end
```
This call states that our %Album{} schema will have a field called tracks, which
will consist of zero or more instances of the %Track{} struct. In this association,
the %Album{} record is called the parent record and the %Track{} records are
the child records.
For this to work, Ecto will be looking for a column named `album_id` in the tracks
table to connect the tracks to the albums. We built these tables following
Ecto’s conventions, but if you’re working with a legacy database that uses a
different naming scheme, you can still make the association work by specifying
the foreign key explicitly.
For example, if the tracks table used `album_number` rather than `album_id` for the
foreign key, we could create the association like this:

`has_many :tracks, MusicDB.Track, foreign_key: :album_number`

See p55 "Working with associations in queries" of the Programming Ecto book.

Ecto does not lazy load associated records (avoids us getting bitten by the N+1 Query problem)
we have to ask for them to be preloaded:


```elixir
iex> r = Ecto.Query.from(Pentoslime.Catalog.Product,limit: 1)|>Pentoslime.Repo.one
%Pentoslime.Catalog.Product{
  __meta__: #Ecto.Schema.Metadata<:loaded, "products">,
  id: 10,
  description: "Bat the ball back and forth. Don't miss!",
  name: "Table Tennis",
  sku: 15222324,
  unit_price: 12.0,
  image_upload: nil,
  inserted_at: ~N[2022-11-30 19:53:43],
  updated_at: ~N[2022-11-30 19:53:43],
  ratings: #Ecto.Association.NotLoaded<association :ratings is not loaded>
}
iex> r.ratings                                                                    
#Ecto.Association.NotLoaded<association :ratings is not loaded>
iex> r = Ecto.Query.from(Pentoslime.Catalog.Product,limit: 1, preload: :ratings)|>Pentoslime.Repo.one
%Pentoslime.Catalog.Product{
  __meta__: #Ecto.Schema.Metadata<:loaded, "products">,
  id: 10,
  description: "Bat the ball back and forth. Don't miss!",
  name: "Table Tennis",
  sku: 15222324,
  unit_price: 12.0,
  image_upload: nil,
  inserted_at: ~N[2022-11-30 19:53:43],
  updated_at: ~N[2022-11-30 19:53:43],
  ratings: [
    %Pentoslime.Survey.Rating{
      __meta__: #Ecto.Schema.Metadata<:loaded, "ratings">,
      id: 6,
      stars: 4,
      user_id: 4,
      user: #Ecto.Association.NotLoaded<association :user is not loaded>,
      product_id: 10,
      product: #Ecto.Association.NotLoaded<association :product is not loaded>,
      inserted_at: ~N[2022-12-14 16:03:20],
      updated_at: ~N[2022-12-14 16:05:34]
    }
  ]
}
iex> r.ratings                                                                                       
[
  %Pentoslime.Survey.Rating{
    __meta__: #Ecto.Schema.Metadata<:loaded, "ratings">,
    id: 6,
    stars: 4,
    user_id: 4,
    user: #Ecto.Association.NotLoaded<association :user is not loaded>,
    product_id: 10,
    product: #Ecto.Association.NotLoaded<association :product is not loaded>,
    inserted_at: ~N[2022-12-14 16:03:20],
    updated_at: ~N[2022-12-14 16:05:34]
  }
]
iex> 
```

To get all users: `Pentoslime.Repo.all(Accounts.User)`

Ecto queries use macros which need us to use the pin operator '^' on expressions which need evaluating.

e.g.
```elixir
  defp for_user(query, user) do
    query
    |> where([r], r.user_id == ^user.id)
  end
```
```elixir
ex> alias Pentoslime.Survey
iex> alias Pentoslime.Accounts
iex> alias Pentoslime.Catalog
iex> user = Accounts.get_user!(3)
iex> Survey.create_rating(%{user_id: user.id, product_id: 8, stars: 2})
iex> Catalog.list_products_with_user_rating(user)
[
  %Pentoslime.Catalog.Product{
    __meta__: #Ecto.Schema.Metadata<:loaded, "products">,
    id: 10,
    description: "Bat the ball back and forth. Don't miss!",
    name: "Table Tennis",
    sku: 15222324,
    unit_price: 12.0,
    image_upload: nil,
    inserted_at: ~N[2022-11-30 19:53:43],
    updated_at: ~N[2022-11-30 19:53:43],
    ratings: []
  },
  ...
  ...
  %Pentoslime.Catalog.Product{
    __meta__: #Ecto.Schema.Metadata<:loaded, "products">,
    id: 8,
    description: "The classic strategy game",
    name: "Chess",
    sku: 14324,
    unit_price: 10.0,
    image_upload: nil,
    inserted_at: ~N[2022-11-30 19:53:43],
    updated_at: ~N[2022-12-13 17:10:51],
    ratings: [
      %Pentoslime.Survey.Rating{
        __meta__: #Ecto.Schema.Metadata<:loaded, "ratings">,
        id: 9,
        stars: 2,
        user_id: 3,
        user: #Ecto.Association.NotLoaded<association :user is not loaded>,
        product_id: 8,
        product: #Ecto.Association.NotLoaded<association :product is not loaded>,
        inserted_at: ~N[2022-12-14 23:39:50],
        updated_at: ~N[2022-12-14 23:39:50]
      }
    ]
  },
  ...
  ...
]
iex> 
```
p164 PPLV

`live_session`
- https://fly.io/phoenix-files/live-session/

- https://fly.io/phoenix-files/

p166 assign_new will only assign `:current_user` if it's not already present in `socket`,
i.e. it will only assign _new_ data.

``` elixir
socket = assign_new(socket, :current_user, fn ->
            Accounts.get_user_by_session_token(user_token)
        end)
```

`SPC-m-p` preview markdow   n

snap Firefox doesn't mount the system /tmp so for emacs `(setq browse-url-browser-function 'browse-url-chrome)`
https://superuser.com/questions/1748689/file-tmp-in-firefox-does-not-show-contents-of-tmp


### p173 PPLV Programming function components.


This is the tightest way I've found to use anonymous functions in pipelines.
```elixir
iex> "s@j.a" |> Accounts.get_user_by_email |> (fn(x)->x.id end).()
2
iex> "s@j.a" |> Accounts.get_user_by_email |> (&(&1.id)).()
2
```

(maybe) Check out http://elixir-recipes.github.io/

Quickly alias multiple names: `alias Pento.{Accounts, Survey, Catalog}`

see https://stackoverflow.com/questions/39637239/alias-multiple-names-in-the-same-line


Function components get their own assigns as you can check with:
```elixir
  def title(assigns) do
    ~H"""
    <h2> <%= @survey_title %> </h2>
    Assigns are: <%= inspect(assigns) %>
    """
  end
```

### The `@` symbol in embeded elixir (EEx,HEEx,sHEEx) 

https://hexdocs.pm/eex/1.12.3/EEx.html

EEx.SmartEngine also adds some macros to your template. An example is the @ macro which allows easy data access in a template:

```elixir
EEx.eval_string("<%= @foo %>", assigns: [foo: 1])
"1"
```

In other words, `<%= @foo %>` translates to:

```elixir
<%= {:ok, v} = Access.fetch(assigns, :foo); v %>
```

The assigns extension is useful when the number of variables required by the template is not specified at compilation time.

## Chapter 7 Live Components 


Aside: `@impl true` was a recommended way to indicate that the following function
implements a behaviour (is a callback)  it's now deprecated https://hexdocs.pm/elixir/typespecs.html#behaviours

Rerendering triggers

The only reason to re-render the page is if its contents change. The contents of a LiveView are based on its assigns.
So the usual way to re-render a LiveView is to change the value in one of the assigns.

https://elixirforum.com/t/how-to-force-liveview-to-re-render-a-page/37180/4


Delete the demographic associated with a user.
```elixir
iex> "s5@j.a" |> Accounts.get_user_by_email |> Survey.get_demographic_by_user |> Survey.delete_demographic
```
