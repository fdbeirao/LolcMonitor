module LolcMonitorModel exposing (..)

import Bootstrap.Navbar
import Json.Encode
import Json.Decode
import RemoteData exposing (RemoteData)


---- MESSAGES ----


type Msg
    = OnDashboardFetchResult (RemoteData.WebData Dashboard)
    | ValveUpdated Json.Decode.Value
    | BootstrapNavbarMsg Bootstrap.Navbar.State
    | DashboardChannelJoined Json.Encode.Value
    | DashboardChannelJoinError Json.Encode.Value
    | DashboardChannelLeft Json.Encode.Value
    | DashboardChannelCrashed
    | DashboardChannelDisconnected



---- MODEL ----


type alias Model =
    { dashboard : RemoteData.WebData Dashboard
    , bootstrapNavState : Bootstrap.Navbar.State
    , liveDashboardJoined : Bool
    , webSocketsOrigin : String
    }


type alias Dashboard =
    { lolcvalves : List LolcValve
    }


type LolcValve
    = LolcValve
        { id : String
        , position : ValvePosition
        , status : ValveStatus
        , locked : Bool
        , lastUpdate : String
        }


type ValvePosition
    = Normal
    | OutOfNormal


type ValveStatus
    = Open
    | Closed
    | Unknown


getValveId : LolcValve -> String
getValveId (LolcValve { id }) =
    id


getValvePosition : LolcValve -> ValvePosition
getValvePosition (LolcValve { position }) =
    position


getValvePositionText : ValvePosition -> String
getValvePositionText valvePosition =
    case valvePosition of
        Normal ->
            "Normal"

        OutOfNormal ->
            "Out of normal"


getValveStatus : LolcValve -> ValveStatus
getValveStatus (LolcValve { status }) =
    status


getIsValveLocked : LolcValve -> Bool
getIsValveLocked (LolcValve { locked }) =
    locked


getValveLastUpdate : LolcValve -> String
getValveLastUpdate (LolcValve { lastUpdate }) =
    lastUpdate
