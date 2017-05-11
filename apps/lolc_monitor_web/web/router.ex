defmodule LolcMonitorWeb.Router do
  use LolcMonitorWeb.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LolcMonitorWeb do
    pipe_through :browser # Use the default browser stack
    
    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", LolcMonitorWeb do
    pipe_through :api

    get "/dashboard", DashboardController, :index

    get "/available_valves", AvailableValvesController, :index
  end

  scope "/v", LolcMonitorWeb do
    pipe_through :browser

    get "/", FakeValvesController, :index

    get "/hack/:valve_id/normal/open", FakeValvesController, :normal_open
    get "/hack/:valve_id/normal/closed", FakeValvesController, :normal_closed
    get "/hack/:valve_id/out_of_normal/open", FakeValvesController, :out_of_normal_open
    get "/hack/:valve_id/out_of_normal/closed", FakeValvesController, :out_of_normal_closed
    get "/hack/:valve_id/unknown", FakeValvesController, :unknown
  end
end
