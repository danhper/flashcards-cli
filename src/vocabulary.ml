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

type int_hashtbl = (int* string) list [@@deriving yojson { exn = true }]

type t = {
  records: Record.t List.t;
  weights: Int.t String.Table.t;
}

module type Parser = sig
  val parse: String.t -> t
end


let max_weight = 16

let empty = { records = []; weights = String.Table.create () }

let create records = { records; weights = String.Table.create () }

let from_file filename (module P: Parser) = P.parse (In_channel.read_all filename)

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
