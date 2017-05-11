module LolcMonitorView exposing (view)

import Html exposing (Html)
import Html.Attributes
import Html.CssHelpers
import RemoteData exposing (RemoteData)
import LolcMonitorStyles exposing (CssClasses, cssNamespace)
import LolcMonitorModel exposing (Model, Msg, LolcValve, ValvePosition, ValveStatus)
import Bootstrap.Alert
import Bootstrap.Badge
import Bootstrap.Navbar
import Bootstrap.Progress


---- VIEW ----


{ id, class, classList } =
    Html.CssHelpers.withNamespace LolcMonitorStyles.cssNamespace


view : Model -> Html Msg
view model =
    Html.div
        []
        [ menu model
        , dashboard model
        ]


menu : Model -> Html Msg
menu model =
    Bootstrap.Navbar.config LolcMonitorModel.BootstrapNavbarMsg
        |> Bootstrap.Navbar.withAnimation
        |> Bootstrap.Navbar.info
        |> Bootstrap.Navbar.brand
            [ Html.Attributes.href "#" ]
            [ Html.text "LOLC Valves Dashboard" ]
        |> Bootstrap.Navbar.items []
        |> Bootstrap.Navbar.customItems
            [ Bootstrap.Navbar.customItem (websocketStatus model) ]
        |> Bootstrap.Navbar.view model.bootstrapNavState


websocketStatus : Model -> Html Msg
websocketStatus model =
    let
        ( progressClass, progressLabel ) =
            if (model.liveDashboardJoined) then
                ( Bootstrap.Progress.success, Bootstrap.Progress.label "Connected" )
            else
                ( Bootstrap.Progress.warning, Bootstrap.Progress.label "Connecting..." )
    in
        Html.div
            [ class [ LolcMonitorStyles.WebsocketNavbarStatus ] ]
            [ Bootstrap.Progress.progress
                [ Bootstrap.Progress.value 100
                , Bootstrap.Progress.animated
                , progressClass
                , progressLabel
                ]
            ]


dashboard : Model -> Html Msg
dashboard model =
    case model.dashboard of
        RemoteData.NotAsked ->
            Html.text "HTTP Request not made yet"

        RemoteData.Loading ->
            showLoading

        RemoteData.Success dashboard ->
            dashboardItems dashboard.lolcvalves

        RemoteData.Failure reason ->
            showLoadError (reason |> toString)


filterLolcValvesByPosition : List LolcValve -> ValvePosition -> List LolcValve
filterLolcValvesByPosition valves position =
    valves |> List.filter (\valve -> (LolcMonitorModel.getValvePosition valve) == position)


dashboardItems : List LolcValve -> Html Msg
dashboardItems valves =
    Html.div
        []
        [ statusSummary valves
        , lolcValveList valves
        ]


statusSummary : List LolcValve -> Html Msg
statusSummary valves =
    Html.div
        [ class [ LolcMonitorStyles.MarginAround1em ] ]
        [ statusBar valves ]


statusBar : List LolcValve -> Html Msg
statusBar valves =
    let
        totalValves =
            valves
                |> List.length

        outOfNormalValves =
            valves
                |> List.filter
                    (\valve ->
                        (LolcMonitorModel.getValvePosition valve)
                            == LolcMonitorModel.OutOfNormal
                            && (LolcMonitorModel.getValveStatus valve)
                            /= LolcMonitorModel.Unknown
                    )
                |> List.length

        unknownPositionValves =
            valves
                |> List.filter (\valve -> (LolcMonitorModel.getValveStatus valve) == LolcMonitorModel.Unknown)
                |> List.length

        normalPositionValves =
            valves
                |> List.filter (\valve -> (LolcMonitorModel.getValvePosition valve) == LolcMonitorModel.Normal)
                |> List.length

        valveSummaryWithLength =
            valveSummary totalValves
    in
        Bootstrap.Progress.progressMulti
            [ valveSummaryWithLength unknownPositionValves Bootstrap.Progress.warning
            , valveSummaryWithLength outOfNormalValves Bootstrap.Progress.danger
            , valveSummaryWithLength normalPositionValves Bootstrap.Progress.success
            ]


valveSummary : Int -> Int -> Bootstrap.Progress.Option Msg -> List (Bootstrap.Progress.Option Msg)
valveSummary totalValves filteredValves progressFunc =
    let
        percentage =
            round <| ((toFloat <| filteredValves) / (totalValves |> toFloat)) * 100
    in
        if (totalValves <= 0) then
            []
        else
            [ Bootstrap.Progress.value percentage, progressFunc, Bootstrap.Progress.label (filteredValves |> toString) ]

lolcValveList : List LolcValve -> Html Msg
lolcValveList valves =
    let 
        unknownValves =
            filterUnknownValves valves
        outOfNormalValves =
            filterOutOfNormalValves valves
        normalValves =
            filterNormalValves valves
    in
        Html.div
            [ class [ LolcMonitorStyles.MarginLeft1em ] ]
            [ renderLolcGroupOfValves "Unknown status:" unknownValves
            , renderLolcGroupOfValves "Out of normal position:" outOfNormalValves
            , renderLolcGroupOfValves "Normal position:" normalValves
            ]


renderLolcGroupOfValves : String -> List LolcValve -> Html Msg
renderLolcGroupOfValves title valves =
        case valves of
            [] -> 
                Html.text ""
            hasValves -> 
                Html.div 
                    [ ]
                    [ Html.h4 [] [ Html.text title ]
                    , Html.div
                        [ class
                            [ LolcMonitorStyles.HorizontalFlexContainer
                            , LolcMonitorStyles.WrapFlexContainer
                            ]
                        ]
                        (List.map renderLolcValve (hasValves |> List.sortWith valveIdSorter))
                    ]


renderLolcValve : LolcValve -> Html Msg
renderLolcValve valve =
    let
        valveTitle =
            valve |> LolcMonitorModel.getValveId

        valvePosition =
            valve |> LolcMonitorModel.getValvePosition |> toString

        valveStatus =
            valve |> LolcMonitorModel.getValveStatus |> toString

        valveIsLocked =
            valve |> LolcMonitorModel.getIsValveLocked |> toString

        valveContentHtml =
            [ Html.text (valveTitle ++ " - " ++ valveStatus) ]

        badgeHtml =
            case (valve |> LolcMonitorModel.getValvePosition) of
                LolcMonitorModel.OutOfNormal ->
                    case (valve |> LolcMonitorModel.getValveStatus) of
                        LolcMonitorModel.Open ->
                            Bootstrap.Badge.badgeDanger [ class [ LolcMonitorStyles.Width100 ] ] valveContentHtml

                        LolcMonitorModel.Closed ->
                            Bootstrap.Badge.badgeDanger [ class [ LolcMonitorStyles.Width100 ] ] valveContentHtml

                        LolcMonitorModel.Unknown ->
                            Bootstrap.Badge.badgeWarning [ class [ LolcMonitorStyles.Width100 ] ] valveContentHtml

                LolcMonitorModel.Normal ->
                    Bootstrap.Badge.badgeSuccess [ class [ LolcMonitorStyles.Width100 ] ] valveContentHtml
    in
        Html.div [ class [ LolcMonitorStyles.LolcValve ] ] [ badgeHtml ]


showLoading : Html Msg
showLoading =
    Html.div
        [ class [ LolcMonitorStyles.MarginAround1em ] ]
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
        [ class [ LolcMonitorStyles.MarginAround1em ] ]
        [ Bootstrap.Alert.danger
            [ Bootstrap.Alert.h4 [] [ Html.text "Sorry, I was unable to load your data :(" ]
            , Html.text reason
            ]
        ]

valveIdSorter : LolcValve -> LolcValve -> Order
valveIdSorter valveA valveB =
    compare (LolcMonitorModel.getValveId valveA) (LolcMonitorModel.getValveId valveB)


valvePositionSorter : LolcValve -> LolcValve -> Order
valvePositionSorter valveA valveB =
    let
        valveAPosition =
            valveA |> LolcMonitorModel.getValvePosition

        valveBPosition =
            valveB |> LolcMonitorModel.getValvePosition

        valveAStatus =
            valveA |> LolcMonitorModel.getValveStatus

        valveBStatus =
            valveB |> LolcMonitorModel.getValveStatus

        compareByValveId =
            compare (LolcMonitorModel.getValveId valveA) (LolcMonitorModel.getValveId valveB)

        aBeforeB =
            LT

        bBeforeA =
            GT
    in
        case ( valveAPosition, valveBPosition, valveAStatus, valveBStatus ) of
            ( LolcMonitorModel.Normal, LolcMonitorModel.Normal, _, _ ) ->
                compareByValveId

            ( LolcMonitorModel.Normal, LolcMonitorModel.OutOfNormal, _, _ ) ->
                bBeforeA

            ( LolcMonitorModel.OutOfNormal, LolcMonitorModel.Normal, _, _ ) ->
                aBeforeB

            ( LolcMonitorModel.OutOfNormal, LolcMonitorModel.OutOfNormal, LolcMonitorModel.Unknown, LolcMonitorModel.Unknown ) ->
                compareByValveId

            ( LolcMonitorModel.OutOfNormal, LolcMonitorModel.OutOfNormal, LolcMonitorModel.Unknown, LolcMonitorModel.Open ) ->
                aBeforeB

            ( LolcMonitorModel.OutOfNormal, LolcMonitorModel.OutOfNormal, LolcMonitorModel.Unknown, LolcMonitorModel.Closed ) ->
                aBeforeB

            ( LolcMonitorModel.OutOfNormal, LolcMonitorModel.OutOfNormal, LolcMonitorModel.Open, LolcMonitorModel.Unknown ) ->
                bBeforeA

            ( LolcMonitorModel.OutOfNormal, LolcMonitorModel.OutOfNormal, LolcMonitorModel.Closed, LolcMonitorModel.Unknown ) ->
                bBeforeA

            ( LolcMonitorModel.OutOfNormal, LolcMonitorModel.OutOfNormal, _, _ ) ->
                compareByValveId


filterUnknownValves : List LolcValve -> List LolcValve
filterUnknownValves valves =
    valves |> List.filter (\valve -> (LolcMonitorModel.getValveStatus valve) == LolcMonitorModel.Unknown)


filterOutOfNormalValves : List LolcValve -> List LolcValve
filterOutOfNormalValves valves =
    valves |> List.filter (\valve -> (LolcMonitorModel.getValvePosition valve) == LolcMonitorModel.OutOfNormal)
    |> List.filter (\valve -> (LolcMonitorModel.getValveStatus valve) /= LolcMonitorModel.Unknown)

filterNormalValves : List LolcValve -> List LolcValve
filterNormalValves valves =
    valves |> List.filter (\valve -> (LolcMonitorModel.getValvePosition valve) == LolcMonitorModel.Normal)
