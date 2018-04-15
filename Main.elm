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
import Select

{-
Program
-}

main : Program Never Model Msg
main =
    Html.program
        { init = (initialModel, getArticle initialModel)
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


getArticle : Model -> Cmd Msg
getArticle model =
    let
        url =
            "https://newsapi.org/v2/"
            ++ "top-headlines"
            ++ "?country=" ++ String.toLower(toString model.country)
            ++ "&category=" ++ String.toLower(toString model.category)
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
        |> optional "title" Json.Decode.string "(The image is not present)"
        |> optional "description" Json.Decode.string "(The image is not present)"
        |> optional "url" Json.Decode.string "(The image is not present)"
        |> optional "urlToImage" Json.Decode.string "(The image is not present)"
        |> optional "publishedAt" Json.Decode.string "(The date is not present)"
 
{-
MODEL
-}

type alias Model =
    { currentArticles : List ArticleResult,
      category : Category,
      country : Country
    }

type alias ArticleResult =
    { title : String
    , description : String
    , url : String
    , urlToImage : String
    , publishedAt : String
    }

type Category
    = Science
    | Technology
    | Business
    | Entertainment
    | General
    | Health

type Country
    = Us
    | Mx
    | Br
    | Gr
    | Ru
    | Ch
    | Fr

{-
Message
-}

initialModel : Model
initialModel =
    { currentArticles = []
    , category = Science
    , country = Us
    }

type Msg
    = GotArticle (Result Http.Error (List ArticleResult))
    | SetCategory Category
    | SetCountry Country
    | ButtonUpdate
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
            ({ model | category = newCategory}, Cmd.none)

        SetCountry newCountry ->
            ({ model | country = newCountry}, Cmd.none)

        ButtonUpdate ->
            ( model, getArticle model)

{-
VIEW
-}


view : Model -> Html Msg
view model =
    Grid.container [ class "text-center jumbotron" ]
        [ CDN.stylesheet
        , mainContent model
        ]
        
mainContent : { a | currentArticles : List ArticleResult, category : Category, country : Country} -> Html Msg
mainContent model =
    div []
        [ p [] [ h1 [ class "text-primary" ] [ text "News" ] ]
        ,div [ class "text-info" ]
            [ text ("Selected Country: " ++ toString model.country)
            , br [] []
            , text ("Selected Category: " ++ toString model.category)
            , br [] []
            , br [] []
            ]
        ,div []
            [ Select.from [ Us, Mx, Gr, Br, Ru, Ch, Fr ] SetCountry
            , br [] []
            , br [] []
            ]
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
            , br [] []
            , br [] []
            ]
        ,div []
            [ Button.button
                [ Button.outlinePrimary
                , Button.attrs [ onClick (ButtonUpdate) ]
                ]
                [ text "Update" ]
            , br [] []
            , br [] []
            , h5 [] [ text "The lastest news:" ] 

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
