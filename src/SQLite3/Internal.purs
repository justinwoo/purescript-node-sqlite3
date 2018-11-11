module SQLite3.Internal (
  FilePath,
  Query,
  Param,
  DBConnection,
  _newDB,
  _closeDB,
  _queryDB,
  _queryObjectDB
) where

import Prelude

import Effect (Effect)
import Effect.Exception (Error)
import Effect.Uncurried as EU
import Foreign (Foreign)

type FilePath = String
type Query = String
type Param = Foreign

foreign import data DBConnection :: Type

foreign import _newDB :: EU.EffectFn2 FilePath (EU.EffectFn1 DBConnection Unit) Unit

foreign import _closeDB ::
  EU.EffectFn3
    DBConnection
    (EU.EffectFn1 Error Unit)
    (Effect Unit)
    Unit

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
