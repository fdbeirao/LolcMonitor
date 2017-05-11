module FakeValvesMain exposing (main)

import Bootstrap.Alert
import Bootstrap.ButtonGroup
import Bootstrap.Button
import Bootstrap.Dropdown
import Bootstrap.Grid
import Bootstrap.Grid.Row
import Bootstrap.Progress
import FakeValveStyles exposing (CssClasses, cssNamespace)
import Html exposing (Html)
import Html.CssHelpers
import Html.Events
import Http
import Json.Decode exposing (Decoder, Value, andThen)
import Json.Decode.Pipeline exposing (decode, required)
import RemoteData exposing (RemoteData)


---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



---- MODEL -----


type alias Model =
    { availableValves : RemoteData.WebData (List Valve)
    , valvesDropdownState : Bootstrap.Dropdown.State
    , selectedValve : Maybe Valve
    }


type Msg
    = OnAvailableValvesFetchResult (RemoteData.WebData (List Valve))
    | OnValveSelected Valve
    | SetValveAsNormalOpen String
    | SetValveAsNormalClosed String
    | SetValveAsOutOfNormalOpen String
    | SetValveAsOutOfNormalClosed String
    | SetValveAsUnknown String
    | BootstrapValvesDropdownMsg Bootstrap.Dropdown.State
    | HttpRequestResult (RemoteData.WebData String)


type alias Valve =
    { id : String }



---- INIT ----


init : ( Model, Cmd Msg )
init =
    { availableValves = RemoteData.Loading
    , valvesDropdownState = Bootstrap.Dropdown.initialState
    , selectedValve = Nothing
    }
        ! [ fetchAvailableValves ]



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnAvailableValvesFetchResult result ->
            { model | availableValves = result } ! []

        OnValveSelected valve ->
            { model | selectedValve = Just valve } ! []

        SetValveAsNormalOpen valveId ->
            model ! [ issueHttpRequest ("/v/hack/" ++ valveId ++ "/normal/open") ]

        SetValveAsNormalClosed valveId ->
            model ! [ issueHttpRequest ("/v/hack/" ++ valveId ++ "/normal/closed") ]

        SetValveAsOutOfNormalOpen valveId ->
            model ! [ issueHttpRequest ("/v/hack/" ++ valveId ++ "/out_of_normal/open") ]

        SetValveAsOutOfNormalClosed valveId ->
            model ! [ issueHttpRequest ("/v/hack/" ++ valveId ++ "/out_of_normal/closed") ]

        SetValveAsUnknown valveId ->
            model ! [ issueHttpRequest ("/v/hack/" ++ valveId ++ "/unknown") ]

        BootstrapValvesDropdownMsg state ->
            { model | valvesDropdownState = state } ! []

        HttpRequestResult _ ->
            model ! []



---- VIEW ----


{ id, class, classList } =
    Html.CssHelpers.withNamespace FakeValveStyles.cssNamespace


view : Model -> Html Msg
view model =
    Html.div
        []
        [ valveSelection model
        , valveStatusSelection model
        ]


valveSelection : Model -> Html Msg
valveSelection model =
    case model.availableValves of
        RemoteData.NotAsked ->
            Html.text "HTTP Request not made yet. D'hoh!"

        RemoteData.Loading ->
            showLoading

        RemoteData.Success valves ->
            valves |> valveSelectionCombo model

        RemoteData.Failure reason ->
            showLoadError (reason |> toString)


valveSelectionCombo : Model -> List Valve -> Html Msg
valveSelectionCombo model valves =
    let
        dropdownLabel =
            case model.selectedValve of
                Nothing ->
                    "Pick a valve"

                Just valve ->
                    valve.id
    in
        Bootstrap.Grid.container
            []
            [ Html.h4 [] [ Html.text "Pick a valve:" ]
            , Html.div
                [ class [ FakeValveStyles.MarginAround1em ] ]
                [ Bootstrap.Dropdown.dropdown
                    model.valvesDropdownState
                    { options = []
                    , toggleMsg = BootstrapValvesDropdownMsg
                    , toggleButton =
                        Bootstrap.Dropdown.toggle
                            [ Bootstrap.Button.primary ]
                            [ Html.text dropdownLabel ]
                    , items = (valves |> valveDropdownItems)
                    }
                ]
            ]


valveDropdownItems : List Valve -> List (Bootstrap.Dropdown.DropdownItem Msg)
valveDropdownItems valves =
    valves
        |> List.map
            (\valve ->
                Bootstrap.Dropdown.buttonItem [ Html.Events.onClick (OnValveSelected valve) ] [ Html.text valve.id ]
            )


showLoading : Html Msg
showLoading =
    Html.div
        [ class [ FakeValveStyles.MarginAround1em ] ]
        [ Bootstrap.Progress.progress
            [ Bootstrap.Progress.value 100
            , Bootstrap.Progress.animated
            , Bootstrap.Progress.label "Loading your data..."
            , Bootstrap.Progress.height 20
            ]
        ]


showLoadError : String -> Html Msg
showLoadError reason =
    Html.div
        [ class [ FakeValveStyles.MarginAround1em ] ]
        [ Bootstrap.Alert.danger
            [ Bootstrap.Alert.h4 [] [ Html.text "Sorry, I was unable to load your data :(" ]
            , Html.text reason
            ]
        ]


valveStatusSelection : Model -> Html Msg
valveStatusSelection model =
    case model.selectedValve of
        Nothing ->
            Html.text ""

        Just valve ->
            Bootstrap.Grid.container
                []
                (Html.h4 [] [ Html.text ("Specify [" ++ valve.id ++ "]'s status:") ]
                    :: (valveStatusSelectionButtons valve.id)
                )


valveStatusSelectionButtons : String -> List (Html Msg)
valveStatusSelectionButtons selectedValveId =
    [ Html.div
        [ class [ FakeValveStyles.MarginAround1em ] ]
        [ Bootstrap.Button.button
            [ Bootstrap.Button.success
            , Bootstrap.Button.onClick (SetValveAsNormalOpen selectedValveId)
            , Bootstrap.Button.attrs [ class [ FakeValveStyles.ValveActionButton ] ]
            ]
            [ Html.text "Normal position (Open)" ]
        , Bootstrap.Button.button
            [ Bootstrap.Button.success
            , Bootstrap.Button.onClick (SetValveAsNormalClosed selectedValveId)
            , Bootstrap.Button.attrs [ class [ FakeValveStyles.ValveActionButton ] ]
            ]
            [ Html.text "Normal position (Closed)" ]
        ]
    , Html.div
        [ class [ FakeValveStyles.MarginAround1em ] ]
        [ Bootstrap.Button.button
            [ Bootstrap.Button.danger
            , Bootstrap.Button.onClick (SetValveAsOutOfNormalOpen selectedValveId)
            , Bootstrap.Button.attrs [ class [ FakeValveStyles.ValveActionButton ] ]
            ]
            [ Html.text "Out of Normal position (Open)" ]
        , Bootstrap.Button.button
            [ Bootstrap.Button.danger
            , Bootstrap.Button.onClick (SetValveAsOutOfNormalClosed selectedValveId)
            , Bootstrap.Button.attrs [ class [ FakeValveStyles.ValveActionButton ] ]
            ]
            [ Html.text "Out of Normal position (Closed)" ]
        ]
    , Html.div
        [ class [ FakeValveStyles.MarginAround1em ] ]
        [ Bootstrap.Button.button
            [ Bootstrap.Button.warning
            , Bootstrap.Button.onClick (SetValveAsUnknown selectedValveId)
            , Bootstrap.Button.attrs [ class [ FakeValveStyles.ValveActionButton ] ]
            ]
            [ Html.text "Unknown position" ]
        ]
    ]



---- COMMANDS ----


fetchAvailableValves : Cmd Msg
fetchAvailableValves =
    Http.get fetchAvailableValvesUrl availableValvesDecoder
        |> RemoteData.sendRequest
        |> Cmd.map OnAvailableValvesFetchResult


fetchAvailableValvesUrl : String
fetchAvailableValvesUrl =
    "/api/available_valves/"


issueHttpRequest : String -> Cmd Msg
issueHttpRequest url =
    Http.get url (Json.Decode.string)
        |> RemoteData.sendRequest
        |> Cmd.map HttpRequestResult



---- DECODERS ----


availableValvesDecoder : Json.Decode.Decoder (List Valve)
availableValvesDecoder =
    Json.Decode.list lolcValveDecoder


lolcValveDecoder : Json.Decode.Decoder Valve
lolcValveDecoder =
    decode Valve
        |> required "id" Json.Decode.string



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Bootstrap.Dropdown.subscriptions model.valvesDropdownState BootstrapValvesDropdownMsg
        ]
