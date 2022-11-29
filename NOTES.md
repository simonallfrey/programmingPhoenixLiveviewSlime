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

If you don't like `with` you might try: https://hexdocs.pm/monad/Monad.html , which is showcased at https://zohaib.me/monads-in-elixir-2 .
