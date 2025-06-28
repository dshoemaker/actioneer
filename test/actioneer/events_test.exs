defmodule Actioneer.EventsTest do
  use Actioneer.DataCase

  alias Actioneer.Events

  describe "events" do
    alias Actioneer.Events.Event

    import Actioneer.EventsFixtures

    @invalid_attrs %{status: nil, address: nil, description: nil, title: nil, category: nil, latitude: nil, longitude: nil, date_time: nil, max_participants: nil}

    test "list_events/0 returns all events" do
      event = event_fixture()
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      event = event_fixture()
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      valid_attrs = %{status: "some status", address: "some address", description: "some description", title: "some title", category: "some category", latitude: 120.5, longitude: 120.5, date_time: ~U[2025-06-27 16:00:00Z], max_participants: 42}

      assert {:ok, %Event{} = event} = Events.create_event(valid_attrs)
      assert event.status == "some status"
      assert event.address == "some address"
      assert event.description == "some description"
      assert event.title == "some title"
      assert event.category == "some category"
      assert event.latitude == 120.5
      assert event.longitude == 120.5
      assert event.date_time == ~U[2025-06-27 16:00:00Z]
      assert event.max_participants == 42
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      event = event_fixture()
      update_attrs = %{status: "some updated status", address: "some updated address", description: "some updated description", title: "some updated title", category: "some updated category", latitude: 456.7, longitude: 456.7, date_time: ~U[2025-06-28 16:00:00Z], max_participants: 43}

      assert {:ok, %Event{} = event} = Events.update_event(event, update_attrs)
      assert event.status == "some updated status"
      assert event.address == "some updated address"
      assert event.description == "some updated description"
      assert event.title == "some updated title"
      assert event.category == "some updated category"
      assert event.latitude == 456.7
      assert event.longitude == 456.7
      assert event.date_time == ~U[2025-06-28 16:00:00Z]
      assert event.max_participants == 43
    end

    test "update_event/2 with invalid data returns error changeset" do
      event = event_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      event = event_fixture()
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      event = event_fixture()
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
