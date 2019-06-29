port module Firebase.Firebase exposing (FBCommand(..), FBMsg, FBResponse(..), FBUser, PortMsg, decodeAuthState, elmToFb, encodeCredentials, fbToElm, init, push, register, remove, sendToFirebase, set, setUpAuthListener, signin, signinGoogle, signout, subscribe, subscriptions, toFBResponse, userDecoder)

import Json.Decode as Json exposing (..)
import Json.Encode as E


type alias PortMsg =
    { message : String, payload : Value }


port elmToFb : PortMsg -> Cmd msg


port fbToElm : (PortMsg -> msg) -> Sub msg



-- ----------------------------------------------
-- Subscriptions
-- ----------------------------------------------


type FBResponse
    = SubscriptionOk
    | UnsubscribeOk
    | NoUserPermission -- user has blocked use
    | CFError
    | NewMessage -- from the subscribed service
    | UnhandledResponse


type alias FBMsg =
    { message : String
    , payload : Value
    }


subscriptions : (PortMsg -> msg) -> Sub msg
subscriptions fbMsgHandler =
    fbToElm fbMsgHandler


toFBResponse s =
    case s of
        "SubscriptionOk" ->
            SubscriptionOk

        "UnsubscribeOk" ->
            UnsubscribeOk

        "NoUserPermission" ->
            NoUserPermission

        "CFError" ->
            CFError

        _ ->
            UnhandledResponse



-- Outgoing messages


type FBCommand
    = StartNotifications String
    | StopNotifications String
    | ListenAuthState



-- fbCommandToString : FBCommand -> String
-- fbCommandToString cmd =
--     case cmd of
--     StartNotifications _ ->
--         "StartNotifications"
--     StopNotifications _ ->
--             "StopNotifications"
--     ListenAuthState ->
--         "ListenAuthState"


sendToFirebase : FBCommand -> Cmd msg
sendToFirebase cmd =
    case cmd of
        StartNotifications userId ->
            elmToFb <| { message = "StartNotifications", payload = E.string userId }

        StopNotifications userId ->
            elmToFb <| { message = "StopNotifications", payload = E.string userId }

        _ ->
            elmToFb <| { message = Debug.toString cmd, payload = E.null }



-- AUTHENTICATION


setUpAuthListener : Cmd msg
setUpAuthListener =
    sendToFirebase ListenAuthState


type alias FBUser =
    { email : String
    , uid : String
    , displayName : Maybe String
    , photoURL : Maybe String
    }


init : FBUser
init =
    { email = ""
    , uid = ""
    , displayName = Nothing
    , photoURL = Nothing
    }


decodeAuthState : Decoder (Result String FBUser)
decodeAuthState =
    oneOf
        [ map Ok userDecoder
        , null (Err "nouser")
        ]


userDecoder : Decoder FBUser
userDecoder =
    map4 FBUser
        (field "email" string)
        (field "uid" string)
        (maybe <| field "displayName" string)
        (maybe <| field "photoURL" string)


encodeCredentials : String -> String -> Value
encodeCredentials email password =
    E.object
        [ ( "email", E.string email )
        , ( "password", E.string password )
        ]


signin : String -> String -> Cmd msg
signin email password =
    elmToFb <| FBMsg "signin" (encodeCredentials email password)


signinGoogle : Cmd msg
signinGoogle =
    elmToFb <| FBMsg "signinGoogle" E.null


signout : Cmd msg
signout =
    elmToFb <| FBMsg "signout" E.null


register : String -> String -> Cmd msg
register email password =
    elmToFb <| FBMsg "register" (encodeCredentials email password)



-- DATABASE


subscribe : String -> Cmd msg
subscribe ref =
    elmToFb <| FBMsg "subscribe" <| E.string ref


push : String -> E.Value -> Cmd msg
push ref val =
    [ ( "ref", E.string ref )
    , ( "payload", val )
    ]
        |> E.object
        |> FBMsg "push"
        |> elmToFb


set : String -> E.Value -> Cmd msg
set ref val =
    [ ( "ref", E.string ref )
    , ( "payload", val )
    ]
        |> E.object
        |> FBMsg "set"
        |> elmToFb


remove : String -> Cmd msg
remove ref =
    elmToFb <| FBMsg "remove" (E.string ref)
