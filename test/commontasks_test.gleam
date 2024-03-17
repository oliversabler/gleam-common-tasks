import gleeunit
import gleeunit/should
import gleam/json
import commontasks/jsonparsing
import commontasks/sqlitedb
import simplifile.{delete}

pub fn main() {
  gleeunit.main()
}

// JSON Parsing
pub fn item_to_json_test() {
  let item =
    jsonparsing.Item(
      id: 123,
      content: "much text",
      is_done: False,
      user: jsonparsing.User(id: 100, name: "my name"),
    )

  let _ =
    jsonparsing.item_to_json(item)
    |> json.to_string()
    |> should.equal(
      "{\"id\":123,\"content\":\"much text\",\"is_done\":false,\"user\":{\"id\":100,\"content\":\"my name\"}}",
    )
}

pub fn items_to_json_test() {
  let item1 =
    jsonparsing.Item(
      id: 123,
      content: "much text",
      is_done: False,
      user: jsonparsing.User(id: 100, name: "my name"),
    )

  let item2 =
    jsonparsing.Item(
      id: 456,
      content: "more text",
      is_done: True,
      user: jsonparsing.User(id: 200, name: "your name"),
    )

  let items = [item1, item2]

  let _ =
    jsonparsing.items_to_json(items)
    |> json.to_string()
    |> should.equal(
      "[{\"id\":123,\"content\":\"much text\",\"is_done\":false,\"user\":{\"id\":100,\"content\":\"my name\"}},{\"id\":456,\"content\":\"more text\",\"is_done\":true,\"user\":{\"id\":200,\"content\":\"your name\"}}]",
    )
}

pub fn user_to_json_test() {
  let user = jsonparsing.User(id: 1, name: "some name")

  let _ =
    jsonparsing.user_to_json(user)
    |> json.to_string()
    |> should.equal("{\"id\":1,\"content\":\"some name\"}")
}

// SQLite
pub fn sqlite_create_test() {
  let db_name = "create_test.sqlite3"
  let assert Ok(_) = sqlitedb.connect(db_name, sqlitedb.create_schema)
  use db_connection <- sqlitedb.connect(db_name)

  let vegetable = sqlitedb.Vegetable(1, "Cabbage", "Europe")
  let create = sqlitedb.create(vegetable, db_connection)
  let assert Ok(id) = create

  id
  |> should.equal(1)

  sqlite_cleanup(db_name)
}

pub fn sqlite_read_test() {
  let db_name = "read_test.sqlite3"
  let assert Ok(_) = sqlitedb.connect(db_name, sqlitedb.create_schema)
  use db_connection <- sqlitedb.connect(db_name)

  let vegetable = sqlitedb.Vegetable(1, "Cabbage", "Europe")
  let _ = sqlitedb.create(vegetable, db_connection)

  let read = sqlitedb.read(1, db_connection)
  let assert Ok(vegetable_read) = read

  vegetable_read.id
  |> should.equal(1)

  vegetable_read.name
  |> should.equal("Cabbage")

  vegetable_read.origin
  |> should.equal("Europe")

  sqlite_cleanup(db_name)
}

pub fn sqlite_update_test() {
  let db_name = "update_test.sqlite3"
  let assert Ok(_) = sqlitedb.connect(db_name, sqlitedb.create_schema)
  use db_connection <- sqlitedb.connect(db_name)

  let vegetable = sqlitedb.Vegetable(1, "Cabbage", "Europe")
  let _ = sqlitedb.create(vegetable, db_connection)

  let vegetable_update = sqlitedb.Vegetable(1, "Carrot", "Persia")
  let update = sqlitedb.update(vegetable_update, db_connection)
  let assert Ok(vegetable_update) = update

  vegetable_update.id
  |> should.equal(1)

  vegetable_update.name
  |> should.equal("Carrot")

  vegetable_update.origin
  |> should.equal("Persia")

  sqlite_cleanup(db_name)
}

pub fn sqlite_delete_test() {
  let db_name = "delete_test.sqlite3"
  let assert Ok(_) = sqlitedb.connect(db_name, sqlitedb.create_schema)
  use db_connection <- sqlitedb.connect(db_name)

  let vegetable = sqlitedb.Vegetable(1, "Cabbage", "Europe")
  let _ = sqlitedb.create(vegetable, db_connection)

  let _ =
    sqlitedb.delete(1, db_connection)
    |> should.equal(Nil)

  sqlite_cleanup(db_name)
}

fn sqlite_cleanup(name: String) {
  let _ = delete(file_or_dir_at: "./" <> name)
}
