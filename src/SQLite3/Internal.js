var sqlite3 = require("sqlite3");

exports.newDB = function(filename, cb) {
  cb(new sqlite3.Database(filename))();
};

exports.closeDB = function(db) {
  db.close();
};

exports.queryDB = function(db, query, params, eb, cb) {
  db.all.apply(
    db,
    [query].concat(
      params.concat(function(err, rows) {
        if (err) {
          eb(err);
        } else {
          cb(rows);
        }
      })
    )
  );
};

exports.queryObjectDB = function(db, query, params, eb, cb) {
  db.all(query, params, function(err, rows) {
    if (err) {
      eb(err);
    } else {
      cb(rows);
    }
  });
};
