open Core

let dir =
  let default = Filename.of_parts [ Sys.getenv_exn "HOME"; ".flashcards" ] in
  Option.value ~default (Sys.getenv "FLASHCARDS_HOME")

let expand_path_variables path =
  let parts = Filename.parts path in
  let process_part part =
    String.chop_prefix ~prefix:"$" part
    |> Option.value_map ~f:Sys.getenv_exn ~default:part
  in
  let processed_parts = List.map parts ~f:process_part in
  Filename.of_parts
    (match processed_parts with
    | "." :: p :: tail when String.is_prefix ~prefix:"/" p -> p :: tail
    | _ -> processed_parts)

let config_path = Filename.concat dir "config.json"
let weights_path = Filename.concat dir "weights.json"

type t = {
  vocabulary_path : string;
  search_url : string option; [@default None]
}
[@@deriving yojson { exn = true }]

let create vocabulary_path = { vocabulary_path; search_url = None }

let from_file filepath =
  let json = Yojson.Safe.from_file filepath in
  let { vocabulary_path; search_url } = of_yojson_exn json in
  { vocabulary_path = expand_path_variables vocabulary_path; search_url }

let to_file t filepath =
  let json = to_yojson t in
  Yojson.Safe.to_file filepath json

let load () = from_file config_path
let save t = to_file t config_path
let vocabulary_path { vocabulary_path; _ } = vocabulary_path
let search_url { search_url; _ } = search_url
