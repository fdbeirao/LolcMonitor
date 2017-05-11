# LolcMonitor

This project was used for the Innovation Experience 2017 event on [eVision](http://www.evision-software.com).

## Prerequisites

**Elixir:** http://elixir-lang.org v. 1.4.2, with Erlang OTP 19.0 (64-bit)

**ELM Platform:** http://elm-lang.org v. 0.18

**node.js** https://nodejs.org v. 7.10.0 64bit

**VSCode:** https://code.visualstudio.com
  * Extensions:
    * elm
    * vscode-elixir

**elm-format** `npm install --global elm-format`

**elm-github-install:**
```
npm install --global elm-github-install
```

### First execution (on a Windows machine):

```
mix deps.get
```
(Answer **y** on installing **hex**)


```
mix test
```
(Answer **y** on installing **rebar**)


```
pushd apps\lolc_monitor_web && npm install && pushd web\elm && elm-github-install && rmdir /Q /S elm-stuff\packages\saschatimme\elm-phoenix\0.2.1\example && popd && popd

mix phoenix.server
```
(Allow `erlang` through the firewall)


```
start http://localhost:4000
start http://localhost:4000/v
```

## Running the tests

To run all the tests **once**
```
mix test
```

To run all the tests in **live/watch mode**
```
mix test.watch
```

## Starting the server

```
iex -S mix phoenix.server
```

## Sending a websocket message from the backend to the browser

```
iex> LolcMonitorWeb.Endpoint.broadcast("dashboard:*", "valve_updated", %{ "some": "content" })
```

## Creating a new valve

```
iex> LolcMonitorBackend.add_valve("VLV-1005")
```

## Setting the status of a valve (after adding it)

```
iex> LolcMonitorBackend.set_valve_status("VLV-1010", :normal, :open)
iex> LolcMonitorBackend.set_valve_status("VLV-1010", :normal, :closed)
iex> LolcMonitorBackend.set_valve_status("VLV-1010", :out_of_normal, :open)
iex> LolcMonitorBackend.set_valve_status("VLV-1010", :out_of_normal, :closed)
iex> LolcMonitorBackend.set_valve_status("VLV-1010", :anything, :anything)
```

## Adding dummy valves

```
iex> LolcMonitorBackend.add_dummy_valves(100)
```