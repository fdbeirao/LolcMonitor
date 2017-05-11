port module Stylesheets exposing (..)

import Css.File
import LolcMonitorStyles
import FakeValveStyles

port files : Css.File.CssFileStructure -> Cmd msg

cssFiles : Css.File.CssFileStructure
cssFiles =
  Css.File.toFileStructure
    [ ("main.css", Css.File.compile [ LolcMonitorStyles.css ]) 
    , ("fake_valves.css", Css.File.compile [ FakeValveStyles.css ]) ]

main : Css.File.CssCompilerProgram
main =
  Css.File.compiler files cssFiles