var sqlite3 = require('sqlite3');

exports._newDB = function (filename, cb) {
  return function () {
    cb(new sqlite3.Database(filename))();
  }
}

exports._closeDB = function (db, cb) {
  return function () {
    db.close();
    cb()();
  }
}

exports._queryDB = function (db, query, params, cb) {
  return function () {
    db.all.apply(db, [query].concat(params.concat(function (err, rows) {
      if (err) {
        throw err;
      } else {
        cb(rows)();
      }
    })));
  }
}
