module FakeValveStyles exposing (css, cssNamespace, CssClasses(..))

import Css
import Css.Namespace


---- STYLES ----


type CssClasses
    = MarginAround1em
    | ValveActionButton


cssNamespace : String
cssNamespace =
    "fakeValves"


css : Css.Stylesheet
css =
    (Css.stylesheet << Css.Namespace.namespace cssNamespace)
        [ Css.class MarginAround1em
            [ Css.margin (1 |> Css.em)
            ]
        , Css.class ValveActionButton
            [ Css.marginRight (1 |> Css.em)
            , Css.marginBottom (3 |> Css.px)
            , Css.width (300 |> Css.px)
            , Css.cursor Css.pointer
            ]
        ]
