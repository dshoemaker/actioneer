defmodule Actioneer.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias Actioneer.Repo
  alias Actioneer.Events.Event
  alias Actioneer.Accounts.User

  @doc """
  Returns the list of events.

  ## Examples

      iex> list_events()
      [%Event{}, ...]

  """
  def list_events do
    Repo.all(Event)
    |> Repo.preload(:creator)
  end

  @doc """
  Returns the list of published events.
  """
  def list_published_events do
    from(e in Event, where: e.status == :published, order_by: [asc: e.date_time])
    |> Repo.all()
    |> Repo.preload(:creator)
  end

  @doc """
  Gets a single event.

  Raises `Ecto.NoResultsError` if the Event does not exist.

  ## Examples

      iex> get_event!(123)
      %Event{}

      iex> get_event!(456)
      ** (Ecto.NoResultsError)

  """
  def get_event!(id) do
    Repo.get!(Event, id)
    |> Repo.preload([:creator, :participants])
  end

  @doc """
  Creates a event.

  ## Examples

      iex> create_event(%{field: value})
      {:ok, %Event{}}

      iex> create_event(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_event(attrs \\ %{}) do
    %Event{}
    |> Event.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a event.

  ## Examples

      iex> update_event(event, %{field: new_value})
      {:ok, %Event{}}

      iex> update_event(event, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_event(%Event{} = event, attrs) do
    event
    |> Event.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a event.

  ## Examples

      iex> delete_event(event)
      {:ok, %Event{}}

      iex> delete_event(event)
      {:error, %Ecto.Changeset{}}

  """
  def delete_event(%Event{} = event) do
    Repo.delete(event)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking event changes.

  ## Examples

      iex> change_event(event)
      %Ecto.Changeset{data: %Event{}}

  """
  def change_event(%Event{} = event, attrs \\ %{}) do
    Event.changeset(event, attrs)
  end

  @doc """
  Join a user to an event as a participant.
  """
  def join_event(event_id, user_id) do
    case Repo.get_by(Ecto.assoc(%Event{id: event_id}, :participants), id: user_id) do
      nil ->
        %Event{id: event_id}
        |> Ecto.build_assoc(:participants)
        |> Ecto.Changeset.change(user_id: user_id)
        |> Repo.insert()
      _participant ->
        {:error, :already_joined}
    end
  end

  @doc """
  Remove a user from an event.
  """
  def leave_event(event_id, user_id) do
    from(ep in "event_participants", where: ep.event_id == ^event_id and ep.user_id == ^user_id)
    |> Repo.delete_all()
  end

  @doc """
  Check if a user is participating in an event.
  """
  def participating?(event_id, user_id) do
    from(ep in "event_participants", where: ep.event_id == ^event_id and ep.user_id == ^user_id)
    |> Repo.exists?()
  end

  @doc """
  Filter events by various criteria.
  """
  def filter_events(filters \\ %{}) do
    query = from(e in Event, where: e.status == :published)

    query
    |> filter_by_category(filters[:category])
    |> filter_by_date_range(filters[:start_date], filters[:end_date])
    |> filter_by_location(filters[:latitude], filters[:longitude], filters[:radius])
    |> order_by([e], asc: e.date_time)
    |> Repo.all()
    |> Repo.preload(:creator)
  end

  defp filter_by_category(query, nil), do: query
  defp filter_by_category(query, category) when category != "" do
    from(e in query, where: e.category == ^category)
  end
  defp filter_by_category(query, _), do: query

  defp filter_by_date_range(query, nil, nil), do: query
  defp filter_by_date_range(query, start_date, end_date) do
    query
    |> filter_by_start_date(start_date)
    |> filter_by_end_date(end_date)
  end

  defp filter_by_start_date(query, nil), do: query
  defp filter_by_start_date(query, start_date) do
    from(e in query, where: e.date_time >= ^start_date)
  end

  defp filter_by_end_date(query, nil), do: query
  defp filter_by_end_date(query, end_date) do
    from(e in query, where: e.date_time <= ^end_date)
  end

  # Simple distance filtering for MVP (can be enhanced with PostGIS later)
  defp filter_by_location(query, nil, nil, _radius), do: query
  defp filter_by_location(query, lat, lng, radius) when not is_nil(lat) and not is_nil(lng) and not is_nil(radius) do
    # Simple bounding box filter (approximate)
    lat_delta = radius / 69.0  # Roughly 69 miles per degree of latitude
    lng_delta = radius / (69.0 * :math.cos(lat * :math.pi / 180))

    from(e in query,
      where: e.latitude >= ^(lat - lat_delta) and
             e.latitude <= ^(lat + lat_delta) and
             e.longitude >= ^(lng - lng_delta) and
             e.longitude <= ^(lng + lng_delta)
    )
  end
  defp filter_by_location(query, _, _, _), do: query
end