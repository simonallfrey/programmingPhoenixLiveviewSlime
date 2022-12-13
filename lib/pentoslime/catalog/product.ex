defmodule Pentoslime.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :description, :string
    field :name, :string
    field :sku, :integer
    field :unit_price, :float
    field :image_upload, :string

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :unit_price, :sku, :image_upload])
    |> validate_required([:name, :description, :unit_price, :sku])
    |> unique_constraint(:sku)
  end

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
  # pattern matching prefered to guards in simple cases
  # https://stackoverflow.com/questions/30589187/elixir-pattern-match-or-guard
  # def reduce_unit_price(product, _attrs) when product.unit_price = nil do
  def reduce_unit_price(%{unit_price: nil}=product,_attrs) do
    product
    |> cast(%{}, [])
    |> validate_required([:unit_price])
  end
  def reduce_unit_price(%{unit_price: oldprice}=product,attrs) do
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
  >
  """
  def reduce_unit_price_beta(%{unit_price: nil}=_product,_attrs) do
    {:error, "require product.unit_price != nil"}
  end
  def reduce_unit_price_beta(%{unit_price: oldprice}=product,attrs) do
    product
    |> cast(attrs, [:unit_price])
    |> validate_number(:unit_price, less_than: oldprice)
  end


end
