import sqlite3 from "sqlite3";

export function _newDB(filename, cb) {
  cb(new sqlite3.Database(filename))();
}

export function _closeDB(db, eb, cb) {
  db.close(function (err) {
    if (err) {
      eb(err);
    } else {
      cb();
    }
  });
}

export function _queryDB(db, query, params, eb, cb) {
  db.all.apply(
    db,
    [query].concat(
      params.concat(function (err, rows) {
        if (err) {
          eb(err);
        } else {
          cb(rows);
        }
      })
    )
  );
}

export function _queryObjectDB(db, query, params, eb, cb) {
  db.all(query, params, function (err, rows) {
    if (err) {
      eb(err);
    } else {
      cb(rows);
    }
  });
}
