defmodule Pentoslime.SurveyFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pentoslime.Survey` context.
  """

  @doc """
  Generate a demographic.
  """
  def demographic_fixture(attrs \\ %{}) do
    {:ok, demographic} =
      attrs
      |> Enum.into(%{
        gender: "some gender",
        year_of_birth: 42
      })
      |> Pentoslime.Survey.create_demographic()

    demographic
  end

  @doc """
  Generate a rating.
  """
  def rating_fixture(attrs \\ %{}) do
    {:ok, rating} =
      attrs
      |> Enum.into(%{
        stars: 42
      })
      |> Pentoslime.Survey.create_rating()

    rating
  end
end
