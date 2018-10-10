var sqlite3 = require("sqlite3");

exports._newDB = function(filename, cb) {
  cb(new sqlite3.Database(filename))();
};

exports._closeDB = function(db, eb, cb) {
  db.close(function(err) {
    if (err) {
      eb(err);
    } else {
      cb();
    }
  });
};

exports._queryDB = function(db, query, params, eb, cb) {
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

exports._queryObjectDB = function(db, query, params, eb, cb) {
  db.all(query, params, function(err, rows) {
    if (err) {
      eb(err);
    } else {
      cb(rows);
    }
  });
};
