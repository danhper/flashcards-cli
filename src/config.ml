open Core

let dir =
  let default = Filename.of_parts [Sys.getenv_exn "HOME"; ".flashcards"] in
  Option.value ~default (Sys.getenv "FLASHCARDS_HOME")

let config_path = Filename.concat dir "config.json"
let weights_path = Filename.concat dir "weights.json"

type t = {
  vocabulary_path: string;
  search_url: string option [@default None];
} [@@deriving yojson { exn = true }]


let create vocabulary_path = { vocabulary_path; search_url = None; }

let from_file filepath =
  let json = Yojson.Safe.from_file filepath in
  of_yojson_exn json

let to_file t filepath =
  let json = to_yojson t in
  Yojson.Safe.to_file filepath json

let load () = from_file config_path
let save t = to_file t config_path

let vocabulary_path { vocabulary_path; _ } = vocabulary_path
let search_url { search_url; _ } = search_url
