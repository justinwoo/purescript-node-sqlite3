module SQLite3.Internal (
  FilePath,
  Query,
  Param,
  DBConnection,
  newDB,
  closeDB,
  queryDB,
  queryObjectDB
) where

import Prelude

import Effect.Exception (Error)
import Effect.Uncurried as EU
import Foreign (Foreign)

type FilePath = String
type Query = String
type Param = String

foreign import data DBConnection :: Type

foreign import newDB :: EU.EffectFn2 FilePath (EU.EffectFn1 DBConnection Unit) Unit

foreign import closeDB :: EU.EffectFn1 DBConnection Unit

foreign import queryDB ::
  EU.EffectFn5
    DBConnection
    Query
    (Array Param)
    (EU.EffectFn1 Error Unit)
    (EU.EffectFn1 Foreign Unit)
    Unit

foreign import queryObjectDB :: forall params.
  EU.EffectFn5
    DBConnection
    Query
    { | params}
    (EU.EffectFn1 Error Unit)
    (EU.EffectFn1 Foreign Unit)
    Unit
