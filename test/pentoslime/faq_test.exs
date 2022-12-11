defmodule Pentoslime.FAQTest do
  use Pentoslime.DataCase

  alias Pentoslime.FAQ

  describe "questions" do
    alias Pentoslime.FAQ.Question

    import Pentoslime.FAQFixtures

    @invalid_attrs %{answer: nil, q_id: nil, question: nil, upvotes: nil}

    test "list_questions/0 returns all questions" do
      question = question_fixture()
      assert FAQ.list_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert FAQ.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      valid_attrs = %{answer: "some answer", q_id: 42, question: "some question", upvotes: 42}

      assert {:ok, %Question{} = question} = FAQ.create_question(valid_attrs)
      assert question.answer == "some answer"
      assert question.q_id == 42
      assert question.question == "some question"
      assert question.upvotes == 42
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = FAQ.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      update_attrs = %{answer: "some updated answer", q_id: 43, question: "some updated question", upvotes: 43}

      assert {:ok, %Question{} = question} = FAQ.update_question(question, update_attrs)
      assert question.answer == "some updated answer"
      assert question.q_id == 43
      assert question.question == "some updated question"
      assert question.upvotes == 43
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = FAQ.update_question(question, @invalid_attrs)
      assert question == FAQ.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = FAQ.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> FAQ.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = FAQ.change_question(question)
    end
  end

  describe "questions" do
    alias Pentoslime.FAQ.Question

    import Pentoslime.FAQFixtures

    @invalid_attrs %{answer: nil, question: nil, upvotes: nil}

    test "list_questions/0 returns all questions" do
      question = question_fixture()
      assert FAQ.list_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert FAQ.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      valid_attrs = %{answer: "some answer", question: "some question", upvotes: 42}

      assert {:ok, %Question{} = question} = FAQ.create_question(valid_attrs)
      assert question.answer == "some answer"
      assert question.question == "some question"
      assert question.upvotes == 42
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = FAQ.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      update_attrs = %{answer: "some updated answer", question: "some updated question", upvotes: 43}

      assert {:ok, %Question{} = question} = FAQ.update_question(question, update_attrs)
      assert question.answer == "some updated answer"
      assert question.question == "some updated question"
      assert question.upvotes == 43
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = FAQ.update_question(question, @invalid_attrs)
      assert question == FAQ.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = FAQ.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> FAQ.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = FAQ.change_question(question)
    end
  end
end
