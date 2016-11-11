module Main exposing (main)

import Html
import Http
import Json.Decode as Json
import Task exposing (Task)


type alias Datum =
    { categoryId : Json.Value }


type alias Data =
    List Datum


type alias Model =
    { error : Maybe Http.Error
    , response : Maybe Data
    }


type Msg
    = Response (Result Http.Error Data)


main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( Model Nothing Nothing, sendRequest )


sendRequest : Cmd Msg
sendRequest =
    let
        url =
            "https://spreadsheets.google.com/feeds/list/17BBAieK9OnUVwMKXUxR2w6jyVDEjj01sk6-D1oW2KqA/od6/public/values?alt=json"
    in
        Http.send Response (Http.get url decodeResponse)


decodeResponse : Json.Decoder Data
decodeResponse =
    let
        itemDecoder =
            Json.map Datum
                (Json.at [ "gsx$categoryid", "$t" ] Json.value)
    in
        Json.at [ "feed", "entry" ] (Json.list itemDecoder)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        Response dataResult ->
            case dataResult of
                Ok data ->
                    { model | response = Just data } ! []

                Err error ->
                    { model | error = Just error } ! []


view : Model -> Html.Html Msg
view model =
    Html.text <| toString model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
