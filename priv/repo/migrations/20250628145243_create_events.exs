defmodule Actioneer.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :title, :string, null: false
      add :description, :text, null: false
      add :address, :string
      add :latitude, :float
      add :longitude, :float
      add :date_time, :utc_datetime, null: false
      add :category, :string, default: "community"
      add :max_participants, :integer
      add :status, :string, default: "draft"
      add :creator_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:events, [:creator_id])
    create index(:events, [:category])
    create index(:events, [:status])
    create index(:events, [:date_time])
    create index(:events, [:latitude, :longitude])
  end
end
