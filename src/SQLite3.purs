module SQLite3 where

import Prelude

import Data.Either (Either(..))
import Data.Function.Uncurried (Fn5, runFn2, runFn5)
import Data.Function.Uncurried as FU
import Effect (Effect)
import Effect.Aff (Aff, makeAff)
import Effect.Exception (Error)
import Foreign (Foreign)

type FilePath = String
type Query = String
type Param = String

foreign import data DBConnection :: Type

foreign import _newDB ::
  FU.Fn2
    FilePath
    (DBConnection -> Effect Unit)
  (Effect Unit)

foreign import _closeDB ::
    DBConnection ->
    (Effect Unit)

foreign import _queryDB ::
  Fn5
    DBConnection
    Query
    (Array Param)
    (Error -> Effect Unit)
    (Foreign -> Effect Unit)
  (Effect Unit)

newDB :: FilePath -> Aff DBConnection
newDB path =
  makeAff \cb -> mempty <$ runFn2 _newDB path (cb <<< pure)

closeDB :: DBConnection -> Effect Unit
closeDB conn = _closeDB conn

queryDB :: DBConnection -> Query -> Array Param -> Aff Foreign
queryDB conn query params =
  makeAff \cb -> mempty <$ runFn5 _queryDB conn query params (cb <<< Left) (cb <<< Right)
