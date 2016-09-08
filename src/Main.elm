import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder)
import Task
import Debug exposing (..)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)

main : Program Never
main =
    Html.program
        { init = init 37.8267 -122.423
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }

-- MODEL

type alias HourlyDataModel =
  { time: Int,
    summary: String,
    icon: String,
    precipIntensity: Float,
    precipProbability: Float,
    temperature: Float,
    apparentTemperature: Float,
    dewPoint: Float,
    humidity: Float,
    windSpeed: Float,
    windBearing: Int,
    visibility: Float,
    cloudCover: Float,
    pressure: Float,
    ozone: Float
  }

type alias HourlyModel =
  { summary: String,
    icon: String,
    data: List HourlyDataModel
  }

type alias Model =
  { hourly: Maybe HourlyModel,
    latitude: Float,
    longitude: Float
  }

init : Float -> Float -> (Model, Cmd Msg)
init latitude longitude =
  ({  latitude = latitude
    , longitude = longitude }
    , getWeather latitude longitude
  )

-- UPDATE


type Msg
  = Update
  | FetchSucceed String
  | FetchFail Http.Error


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Update ->
      (model, getWeather model.latitude model.longitude)

    FetchSucceed hourly ->
      ({ model | hourly = hourly }, Cmd.none)

    FetchFail _ ->
      (model, Cmd.none)



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h2 [] [text model.longitude.toString]
    , button [ onClick Update ] [ text "Update!" ]
    , br [] []
    ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- HTTP


getWeather : Float -> Float -> Cmd Msg
getWeather latitude longitude =
  let
    url =
      "https://api.forecast.io/forecast/4a726f371f08249dadae62caaacfdcd8/" ++ latitude ++ "," ++ longitude
  in
    Task.perform FetchFail FetchSucceed (Http.get decodeWeather url)


decodeWeather : Decoder HourlyModel
decodeWeather =
  decode HourlyModel
    |> Json.Decode.Pipeline.required "hourly" HourlyModel
