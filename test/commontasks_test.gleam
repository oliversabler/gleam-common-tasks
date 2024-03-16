import gleeunit
import gleeunit/should
import gleam/json
import commontasks/jsonparsing

pub fn main() {
  gleeunit.main()
}

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
