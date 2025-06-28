defmodule ActioneerWeb.EventController do
  use ActioneerWeb, :controller

  alias Actioneer.Events
  alias Actioneer.Events.Event

  def index(conn, params) do
    filter_category = params["category"]
    
    events = case filter_category do
      "environment" -> Events.filter_events(%{category: :environment})
      "culture" -> Events.filter_events(%{category: :culture})
      "voting" -> Events.filter_events(%{category: :voting})
      "community" -> Events.filter_events(%{category: :community})
      "other" -> Events.filter_events(%{category: :other})
      _ -> Events.list_published_events()
    end
    
    render(conn, :index, events: events, filter_category: filter_category)
  end

  def new(conn, _params) do
    # Set default date_time to tomorrow at noon (naive datetime for local timezone)
    tomorrow_noon = 
      Date.utc_today()
      |> Date.add(1)
      |> NaiveDateTime.new!(~T[12:00:00])
    
    changeset = Events.change_event(%Event{}, %{date_time: tomorrow_noon})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    current_user = conn.assigns.current_user
    event_params = Map.put(event_params, "creator_id", current_user.id)

    case Events.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: ~p"/events/#{event}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    current_user = conn.assigns[:current_user]
    
    participating = if current_user do
      Events.participating?(event.id, current_user.id)
    else
      false
    end
    
    render(conn, :show, event: event, participating: participating)
  end

  def edit(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    current_user = conn.assigns.current_user

    if event.creator_id == current_user.id do
      changeset = Events.change_event(event)
      render(conn, :edit, event: event, changeset: changeset)
    else
      conn
      |> put_flash(:error, "You can only edit your own events.")
      |> redirect(to: ~p"/events/#{event}")
    end
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Events.get_event!(id)
    current_user = conn.assigns.current_user

    if event.creator_id == current_user.id do
      case Events.update_event(event, event_params) do
        {:ok, event} ->
          conn
          |> put_flash(:info, "Event updated successfully.")
          |> redirect(to: ~p"/events/#{event}")

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, :edit, event: event, changeset: changeset)
      end
    else
      conn
      |> put_flash(:error, "You can only edit your own events.")
      |> redirect(to: ~p"/events/#{event}")
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    current_user = conn.assigns.current_user

    if event.creator_id == current_user.id do
      {:ok, _event} = Events.delete_event(event)

      conn
      |> put_flash(:info, "Event deleted successfully.")
      |> redirect(to: ~p"/events")
    else
      conn
      |> put_flash(:error, "You can only delete your own events.")
      |> redirect(to: ~p"/events/#{event}")
    end
  end

  def join(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user

    case Events.join_event(id, current_user.id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Successfully joined the event!")
        |> redirect(to: ~p"/events/#{id}")

      {:error, :already_joined} ->
        conn
        |> put_flash(:info, "You are already participating in this event.")
        |> redirect(to: ~p"/events/#{id}")

      {:error, _} ->
        conn
        |> put_flash(:error, "Unable to join event.")
        |> redirect(to: ~p"/events/#{id}")
    end
  end

  def leave(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    Events.leave_event(id, current_user.id)

    conn
    |> put_flash(:info, "You have left the event.")
    |> redirect(to: ~p"/events/#{id}")
  end
end
