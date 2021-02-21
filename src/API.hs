{-# LANGUAGE DuplicateRecordFields #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE NamedFieldPuns #-}

module API
  ( app
  , httpEndpoint
  ) where

import Control.Applicative ((<|>))
import Control.Monad.IO.Class (liftIO)
import Data.Morpheus (App, deriveApp, runApp)
import Data.Morpheus.Subscriptions
  ( Event(..)
  , Hashable
  , httpPubApp
  , webSocketsApp
  )

import Data.Morpheus.App (MapAPI)
import Data.Morpheus.Server (httpPlayground)
import Data.Morpheus.Types
  ( ComposedResolver
  , ID
  , QUERY
  , Resolver
  , ResolverQ
  , RootResolver(..)
  , Undefined(..)
  , lift
  , render
  , subscribe
  )
import Data.Text (Text)
import DataSource (DeityReq(..), Haxl, State(DeityState))
import Haxl.Core (dataFetch, initEnv, runHaxl, stateEmpty, stateSet)
import Server.Utils (isSchema)
import Web.Scotty (RoutePattern, ScottyM, body, get, post, raw)

import Schema

-- FETCH
getDeityIds :: Haxl [ID]
getDeityIds = dataFetch GetDeityIds

getDeityNameById :: ID -> Haxl Text
getDeityNameById = dataFetch . GetDeityNameById

getDeityPowerById :: ID -> Haxl (Maybe Text)
getDeityPowerById = dataFetch . GetDeityPowerById

-- RESOLVERS
getDeityById :: ID -> ResolverQ e Haxl Deity
getDeityById deityId =
  pure
    Deity
      { name = lift (getDeityNameById deityId)
      , power = lift (getDeityPowerById deityId)
      }

resolveDeity :: DeityArgs -> ResolverQ e Haxl Deity
resolveDeity DeityArgs {deityId} = getDeityById deityId

resolveDeities :: ComposedResolver QUERY e Haxl [] Deity
resolveDeities = do
  ids <- lift getDeityIds
  traverse getDeityById ids

resolveQuery :: Query (Resolver QUERY e Haxl)
resolveQuery = Query {deity = resolveDeity, deities = resolveDeities}

rootResolver :: RootResolver Haxl () Query Undefined Undefined
rootResolver =
  RootResolver
    { queryResolver = resolveQuery
    , mutationResolver = Undefined
    , subscriptionResolver = Undefined
    }

app = deriveApp rootResolver

httpEndpoint :: RoutePattern -> App () Haxl -> ScottyM ()
httpEndpoint route app' = do
  get route $ (isSchema *> raw (render app)) <|> raw httpPlayground
  post route $ raw =<< (liftIO . runHaxlApp app' =<< body)

runHaxlApp :: MapAPI a b => App e Haxl -> a -> IO b
runHaxlApp haxlApp input = do
  let stateStore = stateSet DeityState stateEmpty
  environment <- initEnv stateStore ()
  runHaxl environment (runApp haxlApp input)
