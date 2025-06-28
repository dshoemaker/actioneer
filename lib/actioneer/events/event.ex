defmodule Actioneer.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset
  alias Actioneer.Accounts.User

  schema "events" do
    field :title, :string
    field :description, :string
    field :address, :string
    field :latitude, :float
    field :longitude, :float
    field :date_time, :utc_datetime
    field :category, Ecto.Enum, values: [:environment, :culture, :voting, :community, :other], default: :community
    field :max_participants, :integer
    field :status, Ecto.Enum, values: [:draft, :published, :cancelled, :completed], default: :draft

    belongs_to :creator, User
    many_to_many :participants, User, join_through: "event_participants"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:title, :description, :address, :latitude, :longitude, :date_time, :category, :max_participants, :status, :creator_id])
    |> validate_required([:title, :description, :date_time, :category, :creator_id])
    |> validate_length(:title, min: 3, max: 100)
    |> validate_length(:description, min: 10, max: 2000)
    |> validate_future_date(:date_time)
    |> validate_number(:max_participants, greater_than: 0)
    |> foreign_key_constraint(:creator_id)
  end

  defp validate_future_date(changeset, field) do
    validate_change(changeset, field, fn field, value ->
      if DateTime.compare(value, DateTime.utc_now()) == :gt do
        []
      else
        [{field, "must be in the future"}]
      end
    end)
  end
end
