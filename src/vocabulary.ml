open Core

module Record = struct
  type t = {
    word: String.t;
    translation: String.t;
    notes: String.t Option.t;
  }

  let create word translation notes = { word; translation; notes }
  let format { word; translation; notes } =
    let f notes = " − " ^ notes in
    word ^ ": " ^ translation ^ (Option.value ~default:"" (Option.map ~f notes))
end


module Weights = struct
  type t = Int.t String.Table.t
  type int_hashtbl = (string * int) list [@@deriving yojson]

  let to_json t = int_hashtbl_to_yojson (String.Table.to_alist t)
  let of_json json =
    json
    |> int_hashtbl_of_yojson
    |> Result.map ~f:String.Table.of_alist_exn
    |> Result.ok
end

type t = {
  records: Record.t List.t;
  weights: Weights.t;
}

let max_weight = 16

let empty = { records = []; weights = String.Table.create () }

let create ?weights records =
  let weights = Option.value ~default:(String.Table.create ()) weights in
  { records; weights; }

let size { records; _ } = List.length records

let modify_weight t record ~f =
  let key = record.Record.word in
  let current_weight = Hashtbl.find_or_add t.weights key ~default:(Fn.const 1) in
  let new_weight = f current_weight in
  Hashtbl.set t.weights ~key ~data:new_weight

let increase_weight t record =
  let f w = if w >= max_weight then w else w * 2 in
  modify_weight t record ~f

let decrease_weight t record =
  let f w = if w = 1 then w else w / 2 in
  modify_weight t record ~f

let weights t = t.weights

let search_by_word { records; _ } word =
  let f record =
    let word_tokens = String.split ~on:' ' (String.lowercase record.Record.word) in
    List.exists ~f:((=) (String.lowercase word)) word_tokens
  in
  List.find ~f records

let search_by_translation { records; _ } translation =
  let translation = String.lowercase translation in
  let get_translation record = String.lowercase record.Record.translation in
  let exact_f record = get_translation record = translation in
  let fuzzy_f record = String.is_substring ~substring:translation (get_translation record) in
  match List.find ~f:exact_f records with  (* not Option.first_some to keep it lazy *)
  | None -> List.find ~f:fuzzy_f records
  | result -> result

let random_record { records; weights } =
  let append_records acc elem =
    let count = Option.value ~default:1 (Hashtbl.find weights elem.Record.word) in
    let list = List.init count ~f:(const elem) in
    acc @ list
  in
  let weighted_records = List.fold records ~init:[] ~f:append_records in
  List.random_element weighted_records
