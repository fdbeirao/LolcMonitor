defmodule LolcMonitorBackendTest do
  use ExUnit.Case, async: true
  doctest LolcMonitorBackend

  defp get_valves(), do:
    LolcMonitorBackend.get_valves()

  defp get_valves_count(), do:
    get_valves() |> length

  defp add_random_valve(), do:
    add_valve_with_id("random valve, who cares")

  defp add_valve_with_id(valve_id), do:
    LolcMonitorBackend.add_valve(valve_id)

  defp add_dummy_valves(count), do:
    LolcMonitorBackend.add_dummy_valves()

  setup do
    Application.stop(:lolc_monitor_backend)
    :ok = Application.start(:lolc_monitor_backend)
  end

  test "Initial data is empty" do
    assert get_valves_count() == 0
  end

  test "Adding a random valve increases the number valves by one" do
    initial_valves_count = get_valves_count()
    add_random_valve()
    assert get_valves_count() == initial_valves_count + 1
  end

  test "Adding dummy data creates correct number of valves" do
    add_dummy_valves(1000)
    assert get_valves_count() == 1000
  end

  test "Adding an already existing valve doesn't increase the number of valves" do
    add_valve_with_id("VALVE")
    valves_count = get_valves_count()
    add_valve_with_id("VALVE")
    assert get_valves_count() == valves_count
  end

  test "Calling set_valve_status with a non existing valve creates it" do
    LolcMonitorBackend.set_valve_status("VALVE1", :out_of_normal, :open)
    assert get_valves_count() == 1
  end

  test "get_valves() keeps expected contract" do
    # Initial state => no valves
    assert get_valves() == []
    
    # Add valve => default values
    add_valve_with_id("VALVE1")
    assert get_valves() == [%{id: "VALVE1", locked: false, position: "OutOfNormal", status: "Unknown"}]
    
    # Add same valve => no changes
    add_valve_with_id("VALVE1")
    assert get_valves() == [%{id: "VALVE1", locked: false, position: "OutOfNormal", status: "Unknown"}]

    # Set valve position as out of normal, open
    LolcMonitorBackend.set_valve_status("VALVE1", :out_of_normal, :open)
    assert get_valves() == [%{id: "VALVE1", locked: false, position: "OutOfNormal", status: "Open"}]

    # Set valve position as out of normal, closed
    LolcMonitorBackend.set_valve_status("VALVE1", :out_of_normal, :closed)
    assert get_valves() == [%{id: "VALVE1", locked: false, position: "OutOfNormal", status: "Closed"}]

    # Set valve position as normal, open
    LolcMonitorBackend.set_valve_status("VALVE1", :normal, :open)
    assert get_valves() == [%{id: "VALVE1", locked: false, position: "Normal", status: "Open"}]

    # Set valve position as normal, closed
    LolcMonitorBackend.set_valve_status("VALVE1", :normal, :closed)
    assert get_valves() == [%{id: "VALVE1", locked: false, position: "Normal", status: "Closed"}]

    # Set valve position as garbage => position becomes OutOfNormal, status Unknown
    LolcMonitorBackend.set_valve_status("VALVE1", :garbage, :closed)
    assert get_valves() == [%{id: "VALVE1", locked: false, position: "OutOfNormal", status: "Unknown"}]

    # Set valve position as garbage => position becomes OutOfNormal, status Unknown
    LolcMonitorBackend.set_valve_status("VALVE1", :normal, :garbage)
    assert get_valves() == [%{id: "VALVE1", locked: false, position: "OutOfNormal", status: "Unknown"}]

    # Move the valve back to normal open, and add second valve in out of normal, closed
    LolcMonitorBackend.set_valve_status("VALVE1", :normal, :open)
    LolcMonitorBackend.set_valve_status("VALVE2", :out_of_normal, :closed)
    assert get_valves() == [
      %{id: "VALVE1", locked: false, position: "Normal", status: "Open"},
      %{id: "VALVE2", locked: false, position: "OutOfNormal", status: "Closed"},
    ]

  end
end
