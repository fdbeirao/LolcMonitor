module LolcMonitorStyles exposing (css, cssNamespace, CssClasses(..))

import Css
import Css.Namespace


---- STYLES ----


type CssClasses
    = LolcValve
    | LolcValveGroup
    | LolcValveGroupTitle
    | NormalPosition
    | OutOfNormalPosition
    | VerticalFlexContainer
    | HorizontalFlexContainer
    | SpaceBetweenContentFlex
    | WrapFlexContainer
    | FlexItemSelfAlignedToStart
    | SmallPaddingAround
    | CenteredText
    | BoldText
    | SmallerText
    | Width100
    | MarginAround1em
    | MarginLeft1em
    | WebsocketNavbarStatus


cssNamespace : String
cssNamespace =
    "lolcMonitor"


css : Css.Stylesheet
css =
    (Css.stylesheet << Css.Namespace.namespace cssNamespace)
        [ Css.class LolcValve
            [ Css.width (140 |> Css.px)
            , Css.margin (5 |> Css.px)
            ]
        , Css.class LolcValveGroupTitle
            [ Css.fontSize (1.5 |> Css.em)
            , Css.fontWeight Css.bold
            , Css.padding (10 |> Css.px)
            ]
        , Css.class NormalPosition
            [ Css.borderColor ("#00FF00" |> Css.hex)
            ]
        , Css.class OutOfNormalPosition
            [ Css.borderColor ("#FF0000" |> Css.hex)
            ]
        , Css.class VerticalFlexContainer
            [ Css.displayFlex
            , Css.flexDirection Css.column
            ]
        , Css.class HorizontalFlexContainer
            [ Css.displayFlex
            , Css.flexDirection Css.row
            ]
        , Css.class SpaceBetweenContentFlex
            [ Css.justifyContent Css.spaceBetween
            ]
        , Css.class WrapFlexContainer
            [ Css.flexWrap Css.wrap
            ]
        , Css.class FlexItemSelfAlignedToStart
            [ Css.alignSelf Css.flexStart
            ]
        , Css.class SmallPaddingAround
            [ Css.padding (4 |> Css.px)
            ]
        , Css.class CenteredText
            [ Css.textAlign Css.center 
            ]
        , Css.class BoldText
            [ Css.fontWeight Css.bold
            ]
        , Css.class SmallerText
            [ Css.fontSize Css.smaller
            ]
        , Css.class MarginAround1em
            [ Css.margin (1 |> Css.em)
            ]
        , Css.class MarginLeft1em
            [ Css.marginLeft (1 |> Css.em)
            ]
        , Css.class Width100
            [ Css.width (100 |> Css.pct)
            ]
        , Css.class WebsocketNavbarStatus
            [ Css.width (10 |> Css.em)
            ]
        ]
