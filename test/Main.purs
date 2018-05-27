module Test.Main where

import Prelude

import Data.Either (Either(..))
import Data.Foldable (for_)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Node.FS.Aff (exists, unlink)
import SQLite3 (newDB, queryDB)
import Simple.JSON (read)
import Test.Unit (failure, suite, test)
import Test.Unit.Assert (assert, equal)
import Test.Unit.Main (runTest)

type Row =
  { name :: String
  , detail :: String
  }

main :: Effect Unit
main = launchAff_ do
  let testPath = "./test.sqlite3"
  (flip when) (unlink testPath) =<< exists testPath
  db <- newDB testPath
  _ <- queryDB db
    """
CREATE TABLE IF NOT EXISTS mytable
  ( name text primary key unique
  , detail text
  );
    """ []

  liftEffect $ runTest do
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
        results <- read <$> queryDB db
          """
SELECT name, detail FROM mytable
          """ []
        case results of
          Right (as :: Array Row) ->
            for_ as \a -> do
              equal a.name "aa"
              equal a.detail "bbbb"
          Left e ->
            failure $ "row didn't deserialize correctly: " <> show e
