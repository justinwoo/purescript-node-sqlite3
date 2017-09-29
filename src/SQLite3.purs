module SQLite3 where

import Prelude

import Control.Monad.Aff (Aff, makeAff)
import Control.Monad.Eff (Eff, kind Effect)
import Data.Foreign (Foreign)
import Data.Function.Uncurried (runFn4, runFn2, Fn4, Fn2)
import Data.Monoid (mempty)

type FilePath = String
type Query = String
type Param = String

foreign import data DBConnection :: Type
foreign import data DBEffects :: Effect

foreign import _newDB :: forall e.
  Fn2
    FilePath
    (DBConnection -> Eff (db :: DBEffects | e) Unit)
  (Eff (db :: DBEffects | e) Unit)
foreign import _closeDB :: forall e.
  Fn2
    DBConnection
    (Unit -> Eff (db :: DBEffects | e) Unit)
    (Eff (db :: DBEffects | e) Unit)
foreign import _queryDB :: forall e.
  Fn4
    DBConnection
    Query
    (Array Param)
    (Foreign -> Eff (db :: DBEffects | e) Unit)
  (Eff (db :: DBEffects | e) Unit)

newDB :: forall e. FilePath -> Aff (db :: DBEffects | e) DBConnection
newDB path =
  makeAff \cb -> mempty <$ runFn2 _newDB path (cb <<< pure)
closeDB :: forall e. DBConnection -> Aff (db :: DBEffects | e) Unit
closeDB conn =
  makeAff \cb -> mempty <$ runFn2 _closeDB conn (cb <<< pure)
queryDB :: forall e. DBConnection -> Query -> Array Param -> Aff (db :: DBEffects | e) Foreign
queryDB conn query params =
  makeAff \cb -> mempty <$ runFn4 _queryDB conn query params (cb <<< pure)
