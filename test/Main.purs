module Test.Main where

import Prelude
import Control.Monad.Aff (Canceler, launchAff)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Aff.Console (CONSOLE)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Except (runExcept)
import Data.Either (Either(..))
import Data.Foreign (F)
import Data.Foreign.Class (class IsForeign, read)
import Data.Foreign.Generic (defaultOptions, readGeneric)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Node.FS (FS)
import Node.FS.Aff (exists, unlink)
import SQLite3 (DBEffects, newDB, queryDB)
import Test.Unit (failure, suite, test)
import Test.Unit.Assert (assert, equal)
import Test.Unit.Console (TESTOUTPUT)
import Test.Unit.Main (runTest)

newtype Row = Row
  { name :: String
  , detail :: String
  }
derive instance eqRow :: Eq Row
derive instance grRow :: Generic Row _
instance shRow :: Show Row where
  show = genericShow
instance ifRow :: IsForeign Row where
  read = readGeneric $ defaultOptions {unwrapSingleConstructors = true}

type Effects eff =
  ( fs :: FS
  , db :: DBEffects
  , console :: CONSOLE
  , testOutput :: TESTOUTPUT
  , avar :: AVAR
  | eff
  )

main :: forall eff.
  Eff
    (Effects
      ( err :: EXCEPTION
      | eff
      )
    )
    (Canceler (Effects eff))
main = launchAff do
  let testPath = "./test.sqlite3"
  (flip when) (unlink testPath) =<< exists testPath
  db <- newDB testPath
  queryDB db
    """
CREATE TABLE IF NOT EXISTS mytable
  ( name text primary key unique
  , detail text
  );
    """ []

  liftEff $ runTest do
    suite "SQLite3" do
      test ("db connection worked and created " <> testPath) do
        assert "exists testPath" =<< exists testPath
      test "we can insert rows and retrieve them" do
        _ <- queryDB db
              """
INSERT INTO mytable
  ( name, detail )
  VALUES
  ( 'aa', 'bbbb' )
              """ []
        results :: F (Array Row) <- read <$> queryDB db
          """
SELECT name, detail FROM mytable
          """ []
        case runExcept results of
          Right a ->
            equal a
              [ Row
                  { name: "aa"
                  , detail: "bbbb"
                  }
              ]
          Left e ->
            failure $ "row didn't deserialize correctly: " <> show e
