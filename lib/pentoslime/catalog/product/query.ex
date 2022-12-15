defmodule Pentoslime.Catalog.Product.Query do
  import Ecto.Query
  alias Pentoslime.Catalog.Product
  alias Pentoslime.Survey.Rating

  def base, do: Product

  def with_user_ratings(user) do
    base()
    |> preload_user_ratings(user)
  end

  def preload_user_ratings(query, user) do
    ratings_query = Rating.Query.preload_user(user)
    # preload using a 'table' containing only the ratings
    # given by specified user (not the whole ratings table)
    query
    |> preload(ratings: ^ratings_query)
  end
end
