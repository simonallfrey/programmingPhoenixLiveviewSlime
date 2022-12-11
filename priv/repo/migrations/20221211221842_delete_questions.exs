defmodule Pentoslime.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      remove :q_id
    end
  end
end
