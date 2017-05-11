defmodule LolcMonitorWeb.DashboardController do
  use LolcMonitorWeb.Web, :controller

  def index(conn, _params), do:
    json conn, get_dashboard_payload()

  defp get_dashboard_payload(), do:
    %{ 
      lolcvalves: LolcMonitorBackend.get_valves()
    }

end