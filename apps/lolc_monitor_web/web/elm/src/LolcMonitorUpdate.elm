module LolcMonitorUpdate exposing (Flags, init, update)

import Bootstrap.Navbar
import Http
import List.Extra
import Json.Decode exposing (Decoder, Value, andThen)
import Json.Decode.Pipeline exposing (decode, required, hardcoded)
import LolcMonitorModel exposing (Model, Msg(..), Dashboard, LolcValve, ValvePosition, ValveStatus)
import RemoteData exposing (RemoteData)


---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnDashboardFetchResult result ->
            { model | dashboard = result } ! []

        ValveUpdated valveJson ->
            (handleValveUpdated model valveJson) ! []

        BootstrapNavbarMsg state ->
            { model | bootstrapNavState = state } ! []

        DashboardChannelJoined msg ->
            { model | liveDashboardJoined = True } ! [ fetchDashboard ]

        DashboardChannelJoinError msg ->
            { model | liveDashboardJoined = False } ! []

        DashboardChannelLeft msg ->
            { model | liveDashboardJoined = False } ! []

        DashboardChannelCrashed ->
            { model | liveDashboardJoined = False } ! []

        DashboardChannelDisconnected ->
            { model | liveDashboardJoined = False } ! []


handleValveUpdated : Model -> Json.Decode.Value -> Model
handleValveUpdated model valveJson =
    let
        decodedValve =
            valveJson |> Json.Decode.decodeValue lolcValveDecoder
    in
        case decodedValve of
            Ok lolcValve ->
                case model.dashboard of
                    RemoteData.Success dashboard ->
                        { model | dashboard = updateLolcValveInDashboard dashboard lolcValve }

                    _ ->
                        model

            Err _ ->
                model


updateLolcValveInDashboard : Dashboard -> LolcValve -> RemoteData.WebData Dashboard
updateLolcValveInDashboard dashboard lolcValve =
    RemoteData.succeed (dashboard |> addOrUpdateValve lolcValve)


addOrUpdateValve : LolcValve -> Dashboard -> Dashboard
addOrUpdateValve lolcValve dashboard =
    let
        valveId =
            LolcMonitorModel.getValveId lolcValve

        replacedValveList =
            case dashboard.lolcvalves |> List.Extra.find (\v -> (LolcMonitorModel.getValveId v) == valveId) of
                Just _ ->
                    dashboard.lolcvalves |> updateValve lolcValve

                Nothing ->
                    lolcValve :: dashboard.lolcvalves
    in
        { dashboard | lolcvalves = replacedValveList }


updateValve : LolcValve -> List LolcValve -> List LolcValve
updateValve lolcValve lolcValves =
    let
        valveId =
            LolcMonitorModel.getValveId lolcValve
    in
        lolcValves
            |> List.Extra.replaceIf
                (\v -> (LolcMonitorModel.getValveId v) == valveId)
                lolcValve



---- INIT ----


type alias Flags =
    { webSocketsOrigin : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( bootstrapNavbarState, bootstrapNavbarCmd ) =
            Bootstrap.Navbar.initialState LolcMonitorModel.BootstrapNavbarMsg
    in
        { dashboard = RemoteData.Loading
        , bootstrapNavState = bootstrapNavbarState
        , liveDashboardJoined = False
        , webSocketsOrigin = flags.webSocketsOrigin
        }
            ! [ fetchDashboard, bootstrapNavbarCmd ]



---- COMMANDS ----


fetchDashboard : Cmd Msg
fetchDashboard =
    Http.get fetchDashboardUrl dashboardDecoder
        |> RemoteData.sendRequest
        |> Cmd.map OnDashboardFetchResult


fetchDashboardUrl : String
fetchDashboardUrl =
    "/api/dashboard/"



---- DECODERS ----


dashboardDecoder : Json.Decode.Decoder Dashboard
dashboardDecoder =
    decode Dashboard
        |> required "lolcvalves" (Json.Decode.list lolcValveDecoder)


lolcValveDecoder : Json.Decode.Decoder LolcValve
lolcValveDecoder =
    decode
        (\id position status locked lastUpdate ->
            LolcMonitorModel.LolcValve { id = id, position = position, status = status, locked = locked, lastUpdate = lastUpdate }
        )
        |> required "id" Json.Decode.string
        |> required "position" (Json.Decode.string |> Json.Decode.map decodeValvePosition)
        |> required "status" (Json.Decode.string |> Json.Decode.map decodeValveStatus)
        |> required "locked" Json.Decode.bool
        |> hardcoded "00:00:00"


decodeValvePosition : String -> ValvePosition
decodeValvePosition jsonValvePositionString =
    let
        lowerValvePosition =
            String.toLower jsonValvePositionString
    in
        case lowerValvePosition of
            "normal" ->
                LolcMonitorModel.Normal

            "outofnormal" ->
                LolcMonitorModel.OutOfNormal

            _ ->
                let
                    _ =
                        Debug.log "decodeValvePosition" <|
                            "Couldn't decode value ["
                                ++ jsonValvePositionString
                                ++ "]. Defaulting to [OutOfNormal]"
                in
                    LolcMonitorModel.OutOfNormal


decodeValveStatus : String -> ValveStatus
decodeValveStatus jsonValveStatus =
    let
        lowerValveStatus =
            String.toLower jsonValveStatus
    in
        case lowerValveStatus of
            "open" ->
                LolcMonitorModel.Open

            "closed" ->
                LolcMonitorModel.Closed

            "unknown" ->
                LolcMonitorModel.Unknown

            _ ->
                let
                    _ =
                        Debug.log "decodeValveStatus" <|
                            "Couldn't decode value ["
                                ++ jsonValveStatus
                                ++ "]. Defaulting to [Unknown]"
                in
                    LolcMonitorModel.Unknown
