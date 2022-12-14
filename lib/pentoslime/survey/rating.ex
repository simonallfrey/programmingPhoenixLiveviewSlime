defmodule Pentoslime.Survey.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pentoslime.Catalog.Product
  alias Pentoslime.Accounts.User

  schema "ratings" do
    field :stars, :integer
    belongs_to :user, User
    belongs_to :product, Product
    timestamps()
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:stars, :user_id, :product_id])
    |> validate_required([:stars, :user_id, :product_id])
    |> validate_inclusion(:stars, 1..5)
    # |> unique_constraint(:product_id, name: :index_ratings_on_user_product)
    # when used with a unique_index via name: option, the first argument is
    # only used for the error message, thus:
    |> unique_constraint(:user_can_only_give_one_rating_per_product, name: :index_ratings_on_user_product)
  end
end
