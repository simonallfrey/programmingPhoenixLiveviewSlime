defmodule Pentoslime.FAQFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pentoslime.FAQ` context.
  """

  @doc """
  Generate a unique question q_id.
  """
  def unique_question_q_id, do: System.unique_integer([:positive])

  @doc """
  Generate a question.
  """
  def question_fixture(attrs \\ %{}) do
    {:ok, question} =
      attrs
      |> Enum.into(%{
        answer: "some answer",
        q_id: unique_question_q_id(),
        question: "some question",
        upvotes: 42
      })
      |> Pentoslime.FAQ.create_question()

    question
  end

  @doc """
  Generate a question.
  """
  def question_fixture(attrs \\ %{}) do
    {:ok, question} =
      attrs
      |> Enum.into(%{
        answer: "some answer",
        question: "some question",
        upvotes: 42
      })
      |> Pentoslime.FAQ.create_question()

    question
  end
end
