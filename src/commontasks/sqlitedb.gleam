import gleam/dynamic
import gleam/result
import sqlight

const db_name = "vegetables.sqlite3"

pub type Vegetable {
  Vegetable(id: Int, name: String, origin: String)
}

pub type DbError {
  BadRequest
  ContentRequired
  NotFound
  SqlightError(sqlight.Error)
}

pub fn connect(f: fn(sqlight.Connection) -> a) -> a {
  use db <- sqlight.with_connection(db_name)
  let assert Ok(_) = sqlight.exec("pragma foreign_keys = on;", db)
  f(db)
}

pub fn create_schema(db: sqlight.Connection) -> Result(Nil, DbError) {
  sqlight.exec(
    "create table if not exists vegetables (
        id integer primary key autoincrement not null,
        name text,
        origin text
    );",
    db,
  )
  |> result.map_error(SqlightError)
}

pub fn create(
  vegetable: Vegetable,
  db: sqlight.Connection,
) -> Result(Int, DbError) {
  let query =
    "insert into
        vegetables (
            name,
            origin,
        )
    values
        (?1, ?2)
    returning
        id;"

  use rows <- result.then(
    sqlight.query(
      query,
      on: db,
      with: [sqlight.text(vegetable.name), sqlight.text(vegetable.origin)],
      expecting: dynamic.element(0, dynamic.int),
    )
    |> result.map_error(fn(error) {
      case error.code, error.message {
        sqlight.ConstraintCheck, "CHECK constraint failed: empty_content" ->
          ContentRequired
        _, _ -> BadRequest
      }
    }),
  )

  let assert [id] = rows
  Ok(id)
}

pub fn read(id: Int, db: sqlight.Connection) -> Result(Vegetable, DbError) {
  let query =
    "select
        id,
        name,
        origin,
    from
       vegetables
    where
        id = ?;"

  let assert Ok(rows) =
    sqlight.query(
      query,
      on: db,
      with: [sqlight.int(id)],
      expecting: result_parser(),
    )

  case rows {
    [vegetable] -> Ok(vegetable)
    _ -> Error(NotFound)
  }
}

pub fn update(
  vegetable: Vegetable,
  db: sqlight.Connection,
) -> Result(Vegetable, DbError) {
  let query =
    "update
       vegetables
    set
        name = ?1,
        origin = ?2
    where
        id = ?3
    returning
        id,
        name,
        origin;"

  let assert Ok(rows) =
    sqlight.query(
      query,
      on: db,
      with: [
        sqlight.text(vegetable.name),
        sqlight.text(vegetable.origin),
        sqlight.int(vegetable.id),
      ],
      expecting: result_parser(),
    )

  case rows {
    [vegetable] -> Ok(vegetable)
    _ -> Error(NotFound)
  }
}

pub fn delete(id: Int, db: sqlight.Connection) -> Nil {
  let query =
    "delete from
       vegetables
    where
        id = ?;"

  let assert Ok(_) =
    sqlight.query(query, on: db, with: [sqlight.int(id)], expecting: Ok)

  Nil
}

fn result_parser() -> dynamic.Decoder(Vegetable) {
  dynamic.decode3(
    Vegetable,
    dynamic.element(0, dynamic.int),
    dynamic.element(1, dynamic.string),
    dynamic.element(2, dynamic.string),
  )
}
