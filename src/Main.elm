port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (value, style)
import Html.Attributes as A exposing (style)
import Svg exposing (svg, circle, animate)
import Svg.Attributes as SA

type alias Model =
    { transcription : String
    , isListening : Bool
    , language : String
    , showTranscription : Bool
    }

type Msg
    = StartListening
    | StopListening
    | TranscriptionReceived String
    | LanguageChanged String
    | ErrorOccurred String

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        StartListening ->
            ({ model | isListening = True, showTranscription = False }, startListeningCmd model.language)

        StopListening ->
            ({ model | isListening = False }, stopListeningCmd ())

        TranscriptionReceived transcription ->
            if transcription /= "" then
                ({ model | transcription = transcription, showTranscription = True }, Cmd.none)
            else
                (model, Cmd.none)

        LanguageChanged language ->
            ({ model | language = language }, Cmd.none)

        ErrorOccurred error ->
            ({ model | transcription = "Error: " ++ error, showTranscription = True }, Cmd.none)

svgView : Bool -> Html msg
svgView isListening =
    svg
        [ SA.viewBox "0 0 50 50"
        , SA.class (if isListening then "listening-svg" else "hidden")
        , SA.style "width: 20px; height: 20px; vertical-align: middle; margin-right: 5px; display: inline-block;"
        ]
        [ circle [ SA.cx "25", SA.cy "25", SA.r "20", SA.stroke "#ccc", SA.strokeWidth "2.5", SA.fill "none" ] []
        , circle [ SA.cx "25", SA.cy "25", SA.r "15", SA.stroke "#ccc", SA.strokeWidth "2.5", SA.fill "none" ]
            [ if isListening then
                  animate [ SA.attributeName "r", SA.values "15; 12; 15", SA.dur "1.5s", SA.repeatCount "indefinite" ] []
              else
                  text ""
            ]
        , circle [ SA.cx "25", SA.cy "25", SA.r "2.5", SA.fill "#ccc" ] []
        ]

footerView : Html msg
footerView =
    footer [ A.class "footer" ]
        [ text "Created with ❤️ by "
        , a [ A.href "https://shuchi-mehta-portfolio.web.app/", A.target "_blank", A.rel "noopener noreferrer" ]
            [ text "Shuchi Mehta" ]
        ]

view : Model -> Html Msg
view model =
    div [ A.class "container" ]
        [ div [ A.class "select-wrapper" ] 
            [ select [ A.class "language-select", onInput LanguageChanged ]
                [ option [ value "en-US" ] [ text "English (US)" ]
                , option [ value "es-ES" ] [ text "Spanish (Spain)" ]
                , option [ value "fr-FR" ] [ text "French (France)" ]
                ]
            ] 
        ,h1 [] [ text "Speech to Text.. 💬" ]        
        , div [ A.class "btn-wrapper" ]
            [ button [ onClick StartListening, A.class "btn-start ", A.disabled model.isListening ] 
                [ svgView model.isListening, text "Start Listening" ]
            , button [ onClick StopListening, A.class "btn-stop",  A.disabled (not model.isListening) ] 
                [ text "Stop Listening" ]
            ]
        , if model.showTranscription then
            div [ A.class "result" ] [ text model.transcription ]
          else
            text ""  -- Don't display anything if showTranscription is False
        , footerView
        ]
        

    

port startListeningCmd : String -> Cmd msg
port stopListeningCmd : (() -> Cmd msg)  -- Changed this line to indicate a function returning Cmd

port receiveTranscription : (String -> msg) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
    receiveTranscription TranscriptionReceived

init : () -> (Model, Cmd Msg)
init _ =
    ({ transcription = "", isListening = False, language = "en-US", showTranscription = False }, Cmd.none)

main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
