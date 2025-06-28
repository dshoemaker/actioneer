defmodule Actioneer.Repo.Migrations.EnablePostgisExtension do
  use Ecto.Migration

  def change do
    # PostGIS extension will be added later
    # execute "CREATE EXTENSION IF NOT EXISTS postgis", "DROP EXTENSION IF EXISTS postgis"
  end
end
