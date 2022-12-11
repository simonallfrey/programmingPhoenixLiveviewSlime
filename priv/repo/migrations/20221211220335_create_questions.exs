defmodule Pentoslime.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :question, :string
      add :answer, :string
      add :upvotes, :integer
      add :q_id, :integer

      timestamps()
    end

    create unique_index(:questions, [:q_id])
  end
end
