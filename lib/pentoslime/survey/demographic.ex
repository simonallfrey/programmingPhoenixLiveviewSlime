defmodule Pentoslime.Survey.Demographic do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pentoslime.Accounts.User

# For reference, the migration which producde the demographics table
#
# defmodule Pentoslime.Repo.Migrations.CreateDemographics do
#   use Ecto.Migration

#   def change do
#     create table(:demographics) do
#       add :gender, :string
#       add :year_of_birth, :integer
#       add :user_id, references(:users, on_delete: :nothing)

#       timestamps()
#     end

#     create unique_index(:demographics, [:user_id])
#   end
# end

  schema "demographics" do
    field :gender, :string
    field :year_of_birth, :integer
    # by convention, with the following Ecto will assume that the
    # demographics table has a :user_id that provides the foreign key
    # i.e. the following is equivalent to:
    # belongs_to :user, User, foreign_key: :user_id
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(demographic, attrs) do
    demographic
    |> cast(attrs, [:gender, :year_of_birth, :user_id])
    |> validate_required([:gender, :year_of_birth, :user_id])
    |> validate_inclusion(
    :gender,
    ["male", "female", "other", "prefer not to say"]
    )
    |> validate_inclusion(:year_of_birth, 1900..2022)
    |> unique_constraint(:user_id)
  end
end
