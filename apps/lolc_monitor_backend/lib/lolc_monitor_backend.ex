defmodule LolcMonitorBackend do
  
  # LolcMonitorBackend
  # State representation:
  # %{
  #   :valves = %{}
  # }
  
  def start_link(), do:
    Agent.start_link(&initial_state/0, name: __MODULE__)

  # Public API (all are side effect functions)

  def get_valves(), do:
    Agent.get(__MODULE__, fn state -> 
      state.valves |> to_get_valves_contract()
    end)

  def add_valve(valve_id), do:
    update_valve_state(valve_id, &new_valve/1)

  def set_valve_status(valve_id, position, status) when 
    position in [:normal, :out_of_normal] 
    and status in [:open, :closed], do:
    update_valve_state(valve_id, &(&1 |> in_position(position) |> with_status(status)))

  def set_valve_status(valve_id, _position, _status), do:
    update_valve_state(valve_id, &(&1 |> in_position(:out_of_normal) |> with_status(:unknown)))

  def add_dummy_valves(count \\ 1000), do:
    add_dummy_valve(count)

  # Private Functions

  # Side effect function
  defp update_valve_state(valve_id, update_function), do:
    Agent.update(__MODULE__, fn state ->
      updated_state = Kernel.update_in(state.valves[valve_id], &(&1 |> create_or_update_valve(update_function)))
      updated_state |> publish_valve_state(valve_id) # potential side effect
      updated_state # a function returns the last statement
    end)

  defp create_or_update_valve(:nil, update_function), do:
    new_valve() |> update_function.()
  defp create_or_update_valve(valve, update_function), do:
    valve |> update_function.()

  # Side effect function
  defp publish_valve_state(state, valveId), do:
    with {:ok, func} <- Application.get_env(:lolc_monitor_backend, :broadcast_function),
     do: func.(state.valves[valveId] |> to_valve_contract(valveId))

  defp to_get_valves_contract(valves), do:
    valves
    |> Map.to_list()
    |> Enum.map(fn { key, value } ->
        value |> to_valve_contract(key)
        end)

  defp to_valve_contract(valve, valveId), do:
    valve |> Map.put(:id, valveId)

  defp initial_state(), do:
    %{ valves: %{} }

  defp with_valves(state, valves), do:
    state |> Map.put(:valves, valves)

  defp new_valve(_), do: new_valve()
  defp new_valve(), do:
    %{ } 
    |> in_position(:out_of_normal)
    |> with_status(:unknown)
    |> unlocked()

  defp in_position(valve, :out_of_normal), do:
    valve |> Map.put(:position, "OutOfNormal")
  defp in_position(valve, :normal), do:
    valve |> Map.put(:position, "Normal")

  defp with_status(valve, :open), do:
    valve |> Map.put(:status, "Open")
  defp with_status(valve, :closed), do:
    valve |> Map.put(:status, "Closed")
  defp with_status(valve, :unknown), do:
    valve |> Map.put(:status, "Unknown")

  defp unlocked(valve), do:
    valve |> Map.put(:locked, :false)

  defp locked(valve), do:
    valve |> Map.put(:locked, :true)

  defp add_dummy_valve(0), do: :ok
  defp add_dummy_valve(remaining) do
    valve_id = remaining |> Integer.to_string |> String.rjust(3, ?0)
    set_valve_status("VLV-#{valve_id}", :normal, :open)
    add_dummy_valve(remaining - 1)
  end

end
