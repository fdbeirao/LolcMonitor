defmodule LolcMonitorWeb.AvailableValvesController do
  use LolcMonitorWeb.Web, :controller

  def index(conn, _params), do:
    json conn, get_available_valves_payload()

  defp get_available_valves_payload(), do:
    LolcMonitorBackend.get_valves()
    |> Enum.map(&(&1 |> Map.take([:id])))
    |> Enum.sort()
end