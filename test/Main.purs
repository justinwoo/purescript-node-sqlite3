module Test.Main where

import Prelude

import Data.Either (Either(..))
import Data.Foldable (for_)
import Effect (Effect)
import Effect.Aff (launchAff_)
import Effect.Class (liftEffect)
import Node.FS.Aff (unlink)
import Node.FS.Sync (exists)
import SQLite3 (closeDB, newDB, queryDB, queryObjectDB)
import Simple.JSON (read)
import Test.Unit (failure, suite, test)
import Test.Unit.Assert (assert, equal)
import Test.Unit.Main (runTest)

type TableRow =
  { name :: String
  , detail :: String
  }

main :: Effect Unit
main = launchAff_ do
  let testPath = "./test.sqlite3"
  (flip when) (unlink testPath) =<< liftEffect (exists testPath)
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
        assert "exists testPath" =<< liftEffect (exists testPath)

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
          Right (as :: Array TableRow) ->
            for_ as \a -> do
              equal a.name "aa"
              equal a.detail "bbbb"
          Left e ->
            failure $ "row didn't deserialize correctly: " <> show e

      test "we can use queryObjectDB to retrieve records" do
        results <- read <$> queryObjectDB db "SELECT name, detail FROM mytable WHERE name = $asdf" { "$asdf": "aa" }
        case results of
          Right (as :: Array TableRow) ->
            for_ as \a -> do
              equal a.name "aa"
              equal a.detail "bbbb"
          Left e ->
            failure $ "row didn't deserialize correctly: " <> show e

      test "we can close and re-open a database" do
        let path = "./test-close.sqlite3"
        cDb <- newDB path
        closeDB cDb
        cDb' <- newDB path
        closeDB cDb'
