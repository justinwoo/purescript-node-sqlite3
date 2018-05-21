module SQLite3 where

import Prelude

import Control.Monad.Aff (Aff, Error, makeAff)
import Control.Monad.Eff (Eff, kind Effect)
import Data.Either (Either(..))
import Data.Foreign (Foreign)
import Data.Function.Uncurried (Fn2, Fn5, runFn2, runFn5)
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
    DBConnection ->
    (Eff (db :: DBEffects | e) Unit)

foreign import _queryDB :: forall e.
  Fn5
    DBConnection
    Query
    (Array Param)
    (Error -> Eff (db :: DBEffects | e) Unit)
    (Foreign -> Eff (db :: DBEffects | e) Unit)
  (Eff (db :: DBEffects | e) Unit)

newDB :: forall e. FilePath -> Aff (db :: DBEffects | e) DBConnection
newDB path =
  makeAff \cb -> mempty <$ runFn2 _newDB path (cb <<< pure)

closeDB :: forall e. DBConnection -> Eff (db :: DBEffects | e) Unit
closeDB conn = _closeDB conn

queryDB :: forall e. DBConnection -> Query -> Array Param -> Aff (db :: DBEffects | e) Foreign
queryDB conn query params =
  makeAff \cb -> mempty <$ runFn5 _queryDB conn query params (cb <<< Left) (cb <<< Right)
