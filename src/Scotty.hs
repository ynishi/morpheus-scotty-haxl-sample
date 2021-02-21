{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}

module Scotty
  ( scottyServer
  ) where

import qualified API as Haxl
import Data.Functor.Identity (Identity(..))
import Data.Morpheus (runApp)
import Data.Morpheus.Server (compileTimeSchemaValidation)
import Data.Morpheus.Subscriptions (ServerApp, webSocketsApp)
import Data.Text
import Network.WebSockets.Connection
import Server.Utils (httpEndpoint, startServer)
import Web.Scotty (ScottyM)

scottyServer :: IO ()
scottyServer = do
  startServer wsApp (httpApp)
  where
    httpApp = do
      Haxl.httpEndpoint "/haxl" Haxl.app
    wsApp :: ServerApp
    wsApp pending = do
      conn <- acceptRequest pending
      sendTextData conn ("ws" :: Text)