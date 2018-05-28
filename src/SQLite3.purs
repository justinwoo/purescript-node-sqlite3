module SQLite3 where

import Prelude

import Data.Either (Either(..))
import Effect (Effect)
import Effect.Aff (Aff, makeAff)
import Effect.Exception (Error)
import Effect.Uncurried as EU
import Foreign (Foreign)

type FilePath = String
type Query = String
type Param = String

foreign import data DBConnection :: Type

foreign import _newDB :: EU.EffectFn2 FilePath (EU.EffectFn1 DBConnection Unit) Unit

foreign import _closeDB :: EU.EffectFn1 DBConnection Unit

foreign import _queryDB ::
  EU.EffectFn5
    DBConnection
    Query
    (Array Param)
    (EU.EffectFn1 Error Unit)
    (EU.EffectFn1 Foreign Unit)
    Unit

foreign import _queryObjectDB :: forall params.
  EU.EffectFn5
    DBConnection
    Query
    { | params}
    (EU.EffectFn1 Error Unit)
    (EU.EffectFn1 Foreign Unit)
    Unit

newDB :: FilePath -> Aff DBConnection
newDB path =
  makeAff \cb -> mempty <$ EU.runEffectFn2 _newDB path (EU.mkEffectFn1 $ cb <<< pure)

closeDB :: DBConnection -> Effect Unit
closeDB = EU.runEffectFn1 _closeDB

queryDB :: DBConnection -> Query -> Array Param -> Aff Foreign
queryDB conn query params = makeAff \cb ->
  mempty <$
    EU.runEffectFn5 _queryDB conn query params
      (EU.mkEffectFn1 $ cb <<< Left)
      (EU.mkEffectFn1 $ cb <<< Right)

-- | fairly unsafe function for using an object with a query, see https://github.com/mapbox/node-sqlite3/wiki/API#databaserunsql-param--callback
queryObjectDB :: forall params. DBConnection -> Query -> { | params } -> Aff Foreign
queryObjectDB conn query params = makeAff \cb ->
  mempty <$
    EU.runEffectFn5 _queryObjectDB conn query params
      (EU.mkEffectFn1 $ cb <<< Left)
      (EU.mkEffectFn1 $ cb <<< Right)
