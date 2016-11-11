module Main exposing (main)

import Html exposing (Html)
import Http
import Json.Decode as Json
import ParseInt
import Dict exposing (Dict)


type alias Datum =
    { categoryId : Int
    , group : String
    , item : String
    }


type alias Data =
    List (Maybe Datum)


type alias CleanedObj =
    Dict Int (Dict String (List String))


type alias Model =
    { error : Maybe Http.Error
    , response : Maybe Data
    , cleaned : CleanedObj
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
    ( Model Nothing Nothing Dict.empty, sendRequest )


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
        itemDecoder : Json.Decoder (Maybe Datum)
        itemDecoder =
            Json.maybe
                (Json.at [ "gsx$categoryid", "$t" ] Json.string
                    |> Json.andThen
                        (\idString ->
                            case ParseInt.parseInt idString of
                                Ok id ->
                                    Json.map3 Datum
                                        (Json.succeed id)
                                        (Json.at [ "gsx$group", "$t" ] Json.string)
                                        (Json.at [ "gsx$item", "$t" ] Json.string)

                                Err _ ->
                                    Json.fail "cannot parse id string"
                        )
                )
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


view : Model -> Html Msg
view model =
    Html.div []
        [ detailView model, rawView model ]


detailView model =
    let
        datumView : Maybe Datum -> Html Msg
        datumView datum =
            Html.li [] [ Html.text (toString datum) ]
    in
        Html.div [] (List.map datumView (Maybe.withDefault [] model.response))


rawView model =
    Html.text <| toString model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
