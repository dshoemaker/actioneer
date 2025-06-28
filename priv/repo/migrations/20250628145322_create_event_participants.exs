defmodule Actioneer.Repo.Migrations.CreateEventParticipants do
  use Ecto.Migration

  def change do
    create table(:event_participants, primary_key: false) do
      add :event_id, references(:events, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :status, :string, default: "joined"

      timestamps(type: :utc_datetime)
    end

    create unique_index(:event_participants, [:event_id, :user_id])
    create index(:event_participants, [:event_id])
    create index(:event_participants, [:user_id])
  end
end
