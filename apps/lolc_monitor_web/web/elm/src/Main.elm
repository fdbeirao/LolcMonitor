module Main exposing (main)

import Html
import LolcMonitorUpdate exposing (Flags)
import LolcMonitorModel exposing (Model, Msg(..))
import LolcMonitorView
import Phoenix
import Phoenix.Channel
import Phoenix.Socket


---- PROGRAM ----


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = LolcMonitorUpdate.init
        , update = LolcMonitorUpdate.update
        , subscriptions = subscriptions
        , view = LolcMonitorView.view
        }



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.connect (dashboardSocket model.webSocketsOrigin) [ dashboardChannel ]


dashboardSocket : String -> Phoenix.Socket.Socket a
dashboardSocket webSocketsOrigin =
    Phoenix.Socket.init (webSocketsOrigin ++ "/live/dashboard/websocket")
        |> Phoenix.Socket.reconnectTimer (\failedAttempts -> 10)


dashboardChannel : Phoenix.Channel.Channel Msg
dashboardChannel =
    Phoenix.Channel.init "dashboard:*"
        |> Phoenix.Channel.onJoin DashboardChannelJoined
        |> Phoenix.Channel.onJoinError DashboardChannelJoinError
        |> Phoenix.Channel.onLeave DashboardChannelLeft
        |> Phoenix.Channel.onError DashboardChannelCrashed
        |> Phoenix.Channel.onDisconnect DashboardChannelDisconnected
        |> Phoenix.Channel.on "valve_updated" ValveUpdated
