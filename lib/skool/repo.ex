defmodule Skool.Repo do
  use Ecto.Repo,
    otp_app: :skool,
    adapter: Ecto.Adapters.Postgres
end
