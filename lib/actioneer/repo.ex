defmodule Actioneer.Repo do
  use Ecto.Repo,
    otp_app: :actioneer,
    adapter: Ecto.Adapters.Postgres
end
