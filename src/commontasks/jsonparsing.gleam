import gleam/json
import gleam/list

pub type Item {
  Item(id: Int, content: String, is_done: Bool, user: User)
}

pub type User {
  User(id: Int, name: String)
}

pub fn item_to_json(item: Item) -> json.Json {
  json.object([
    #("id", json.int(item.id)),
    #("content", json.string(item.content)),
    #("is_done", json.bool(item.is_done)),
    #("user", user_to_json(item.user)),
  ])
}

pub fn items_to_json(items: List(Item)) -> json.Json {
  let items_json = list.map(items, fn(item) { item_to_json(item) })
  json.array(items_json, of: fn(item) { item })
}

pub fn user_to_json(user: User) -> json.Json {
  json.object([#("id", json.int(user.id)), #("content", json.string(user.name))])
}
