defmodule Pentoslime.Repo do
  use Ecto.Repo,
    otp_app: :pentoslime,
    adapter: Ecto.Adapters.Postgres
end
