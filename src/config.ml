open Core

let config_path =
  let default = Filename.of_parts [Sys.getenv_exn "HOME"; ".flashcardsrc"] in
  Option.value ~default (Sys.getenv "FLASHCARDSRC")

type t = {
  vocabulary_path: string
} [@@deriving yojson { exn = true }]

let from_file filepath =
  let json = Yojson.Safe.from_file filepath in
  of_yojson_exn json


let to_file t filepath =
  let json = to_yojson t in
  Yojson.Safe.to_file filepath json

let load () = from_file config_path
let save t = to_file t config_path

let vocabulary_path { vocabulary_path } = vocabulary_path
