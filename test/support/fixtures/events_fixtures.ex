defmodule Actioneer.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Actioneer.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        address: "some address",
        category: "some category",
        date_time: ~U[2025-06-27 16:00:00Z],
        description: "some description",
        latitude: 120.5,
        longitude: 120.5,
        max_participants: 42,
        status: "some status",
        title: "some title"
      })
      |> Actioneer.Events.create_event()

    event
  end
end
