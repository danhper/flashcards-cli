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

type t = {
  records: Record.t List.t;
}

module type Parser = sig
  val parse: String.t -> t
end


let empty = { records = [] }

let create records = { records }

let from_file filename (module P: Parser) = P.parse (In_channel.read_all filename)

let size { records; _ } = List.length records

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

let random_record { records; _ } = List.random_element records
