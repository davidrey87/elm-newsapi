module Main exposing (..)

import Use
import Html exposing (..)
import Html.Attributes exposing (class, defaultValue, href, property, target, src, alt, type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (..)
import Bootstrap.CDN as CDN
import Bootstrap.Grid as Grid
import Bootstrap.Button as Button

{-
program
-}

main : Program Never Model Msg
main =
    Html.program
        { init = (initialModel, getArticle initialModel.category)
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


getArticle : Category -> Cmd Msg
getArticle category =
    let
        url =
            "https://newsapi.org/v2/"
            ++ "top-headlines"
            ++ "?country=us"
            ++ "&category=" ++ String.toLower(toString category)
            ++ "&apiKey=" ++ Use.key

        request = Http.get url decodeContent
     in
        Http.send GotArticle request

decodeContent : Decoder (List ArticleResult)
decodeContent =
    Json.Decode.at [ "articles" ] (Json.Decode.list elementsDecoder)

elementsDecoder : Decoder ArticleResult
elementsDecoder =
    decode ArticleResult
        |> optional "title" Json.Decode.string "(The Title is not present)"
        |> optional "description" Json.Decode.string "(The Description is not present)"
        |> optional "url" Json.Decode.string "(The URL is not present)"
        |> optional "urlToImage" Json.Decode.string "(The Image is not present)"
        |> optional "publishedAt" Json.Decode.string "(The Date is not present)"
 
{-
MODEL
-}

type alias Model =
    { currentArticles : List ArticleResult,
      category : Category
    }


type alias ArticleResult =
    { title : String
    , description : String
    , url : String
    , urlToImage : String
    , publishedAt : String
    }

initialModel : Model
initialModel =
    { currentArticles = []
    , category = Science
    }


{-
message
-}

type Category
    = Science
    | Technology
    | Business
    | Entertainment
    | General
    | Health

type Msg
    = GotArticle (Result Http.Error (List ArticleResult))
    | SetCategory Category
    | NoOp

{-
UPDATE
-}

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            (model, Cmd.none)

        GotArticle result ->
            case result of
                Err httpError ->
                    let
                        _ =
                            Debug.log "handleArticleError" httpError
                    in
                        ( model, Cmd.none )

                Ok currentArticles ->
                    ( { model | currentArticles = currentArticles }, Cmd.none )
        
        SetCategory newCategory ->
            ( model, getArticle newCategory)
{-
VIEW
-}

view : Model -> Html Msg
view model =
    Grid.container [ class "text-center jumbotron" ]
        -- Responsive fixed width container
        [ CDN.stylesheet -- Inlined Bootstrap CSS for use with reactor
        , mainContent model
        ]
        
mainContent : { a | currentArticles : List ArticleResult, category : Category} -> Html Msg
mainContent model =
    div []
        [ p [] [ h1 [] [ text "News" ], h5 [] [ text "The lastest news:" ] ]
        ,div []
            [ Button.button
                [ Button.outlinePrimary
                , Button.attrs [ onClick (SetCategory Science) ]
                ]
                [ text "Science" ]
            , Button.button
                [ Button.outlinePrimary
                , Button.attrs [ onClick (SetCategory Technology) ]
                ]
                [ text "Technology" ]
            , Button.button
                [ Button.outlinePrimary
                , Button.attrs [ onClick (SetCategory Business) ]
                ]
                [ text "Business" ]
            , Button.button
                [ Button.outlinePrimary
                , Button.attrs [ onClick (SetCategory Entertainment) ]
                ]
                [ text "Entertainment" ]
            , Button.button
                [ Button.outlinePrimary
                , Button.attrs [ onClick (SetCategory General) ]
                ]
                [ text "General" ]
            , Button.button
                [ Button.outlinePrimary
                , Button.attrs [ onClick (SetCategory Health) ]
                ]
                [ text "Healthl" ]
            ]
        , div [] (List.map viewArticles model.currentArticles)
        , div [ class "text-right small" ]
            [ a [ href "https://github.com/davidrey87/elm-newsapi" ]
                [ text
                    "Source Code"
                ]
            ]
        ]

viewArticles : ArticleResult -> Html Msg
viewArticles result =
    div [class "jumbotron"]
        [ h1 [class "display-10"] [ text result.title ]
        , p [class "lead"] [ text result.description ]
        , p [][ text result.publishedAt]
        , img [ class "img-thumbnail", src (result.urlToImage),  alt (result.description) ] []
        , p [class "lead"][
            a [ class "btn btn-primary btn-lg", href (result.url), target "_blank"]
            [ text "Learn more" ]]
        , hr [class "my-4"][]
        ]

