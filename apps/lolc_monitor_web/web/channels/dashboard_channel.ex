defmodule LolcMonitorWeb.DashboardChannel do
  use Phoenix.Channel

  def join("dashboard:*", _message, socket), do:
    {:ok, socket}

  def publish_dashboard_update(valve_info), do:
    LolcMonitorWeb.Endpoint.broadcast("dashboard:*", "valve_updated", valve_info)
end