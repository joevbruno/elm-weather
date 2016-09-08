import Html exposing (..)
import Html.App as Html
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json exposing (Decoder, decodeValue, succeed, string, oneOf, null, list, bool, (:=))
import Task

main : Program Never
main =
    Html.program
        { init = init 37.8267 -122.423
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }

type alias CompleteForecast = { latitude : Float
                              , longitude : Float
                              , timezone : String
                              , currently : Forecast
                              , hourly : TimespanForecast HourlyForecast
                              , daily : TimespanForecast DailyForecast
                              }


type alias HourlyForecast = { time : Int
                            , summary : String
                            , icon : String
                            , temperature : Float
                            , precipIntensity : Float
                            , precipProbability : Float
                            }


type alias TimespanForecast ft = { summary : String
                                 , icon : String
                                 , forecasts : List ft
                                 }


type alias Forecast = { time : Int
                      , summary : String
                      , icon : String
                      , precipIntensity : Float
                      , precipProbability : Float
                      , temperature : Float
                      , windSpeed : Float
                      , windBearing : Float
                      , humidity : Float
                      , visibility : Float
                      , cloudCover : Float
                      , pressure : Float
                      , ozone : Float
                      }


type alias DailyForecast = { time : Int
                           , summary : String
                           , icon : String
                           , precipIntensity : Float
                           , precipProbability : Float
                           , temperatureMin : Float
                           , temperatureMax : Float
                           }


timespanForecastDecoder : Json.Decoder ft -> Json.Decoder (TimespanForecast ft)
timespanForecastDecoder dataDecoder =
  Json.object3
    TimespanForecast
    ("summary" := Json.string)
    ("icon" := Json.string)
    ("data" := Json.list dataDecoder)


hourlyForecastDecoder : Json.Decoder HourlyForecast
hourlyForecastDecoder =
  Json.object6
    HourlyForecast
    ("time" := Json.int)
    ("summary" := Json.string)
    ("icon" := Json.string)
    ("temperature" := Json.float)
    ("precipIntensity" := Json.float)
    ("precipProbability" := Json.float)


forecastDecoder : Json.Decoder Forecast
forecastDecoder =
  Json.object1 Forecast ("time" := Json.int)
    `apply` ("summary" := Json.string)
    `apply` ("icon" := Json.string)
    `apply` ("precipIntensity" := Json.float)
    `apply` ("precipProbability" := Json.float)
    `apply` ("temperature" := Json.float)
    `apply` ("windSpeed" := Json.float)
    `apply` ("windBearing" := Json.float)
    `apply` ("humidity" := Json.float)
    `apply` ("visibility" := Json.float)
    `apply` ("cloudCover" := Json.float)
    `apply` ("pressure" := Json.float)
    `apply` ("ozone" := Json.float)


dailyForecastDecoder : Json.Decoder DailyForecast
dailyForecastDecoder =
  Json.object7
    DailyForecast
    ("time" := Json.int)
    ("summary" := Json.string)
    ("icon" := Json.string)
    ("precipIntensity" := Json.float)
    ("precipProbability" := Json.float)
    ("temperatureMin" := Json.float)
    ("temperatureMax" := Json.float)


completeForecastDecoder : Json.Decoder (Maybe CompleteForecast)
completeForecastDecoder =
  Json.maybe <|
    Json.object6
      CompleteForecast
      ("latitude" := Json.float)
      ("longitude" := Json.float)
      ("timezone" := Json.string)
      ("currently" := forecastDecoder)
      ("hourly" := (timespanForecastDecoder hourlyForecastDecoder))
      ("daily" := (timespanForecastDecoder dailyForecastDecoder))


apply : Json.Decoder (a -> b) -> Json.Decoder a -> Json.Decoder b
apply func value =
  Json.object2 (<|) func value

-- MODEL
type alias Model =
  { completeForecast: (Maybe CompleteForecast)
    , latitude: Float
    , longitude: Float
  }

init : Float -> Float -> (Model, Cmd Msg)
init latitude longitude =
  ({  completeForecast = Nothing
    , latitude = latitude
    , longitude = longitude }
    , getWeather latitude longitude
  )

-- UPDATE


type Msg
  = Update
  | FetchSucceed (Maybe CompleteForecast)
  | FetchFail Http.Error


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Update ->
      (model, getWeather model.latitude model.longitude)

    FetchSucceed completeForecast ->
      ({ model | completeForecast = completeForecast }, Cmd.none)

    FetchFail _ ->
      (model, Cmd.none)

-- HTTP


getWeather : Float -> Float -> Cmd Msg
getWeather latitude longitude =
  let
    url =
      "https://api.forecast.io/forecast/4a726f371f08249dadae62caaacfdcd8/" ++ toString latitude ++ "," ++ toString longitude
  in
    Task.perform FetchFail FetchSucceed (Http.get completeForecastDecoder url)



-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ h2 [] [text (toString model.longitude)]
    , button [ onClick Update ] [ text "Update!" ]
    , br [] []
    ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
