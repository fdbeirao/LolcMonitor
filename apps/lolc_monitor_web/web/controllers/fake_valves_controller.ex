defmodule LolcMonitorWeb.FakeValvesController do
  use LolcMonitorWeb.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def normal_open(conn, %{ "valve_id" => valve_id }) do
    LolcMonitorBackend.set_valve_status(valve_id, :normal, :open)
    text conn, ":ok"
  end

  def normal_closed(conn, %{ "valve_id" => valve_id }) do
    LolcMonitorBackend.set_valve_status(valve_id, :normal, :closed)
    text conn, ":ok"
  end

  def out_of_normal_open(conn, %{ "valve_id" => valve_id }) do
    LolcMonitorBackend.set_valve_status(valve_id, :out_of_normal, :open)
    text conn, ":ok"
  end

  def out_of_normal_closed(conn, %{ "valve_id" => valve_id }) do
    LolcMonitorBackend.set_valve_status(valve_id, :out_of_normal, :closed)
    text conn, ":ok"
  end

  def unknown(conn, %{ "valve_id" => valve_id }) do
    LolcMonitorBackend.set_valve_status(valve_id, :unknown, :unknown)
    text conn, ":ok"
  end

end
