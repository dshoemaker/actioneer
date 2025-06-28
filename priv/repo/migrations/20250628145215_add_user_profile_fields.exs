defmodule Actioneer.Repo.Migrations.AddUserProfileFields do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string, null: false
      add :role, :string, default: "participant"
      add :zip_code, :string
      add :city, :string
      add :state, :string
      add :bio, :text
    end
  end
end
