{ name = "node-sqlite3"
, dependencies =
  [ "aff"
  , "console"
  , "effect"
  , "foreign"
  , "node-fs-aff"
  , "psci-support"
  , "simple-json"
  , "test-unit"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
