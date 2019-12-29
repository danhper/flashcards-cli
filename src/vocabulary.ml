open Core

module Record = struct
  type t = {
    word: String.t;
    translation: String.t;
    notes: String.t Option.t;
  }

  module FormatOptions = struct
    type t = {
      merge_notes: bool;
      merge_with: string;
      swap_translation: bool;
    }

    let defaults = {
      merge_notes = false;
      merge_with = "\n";
      swap_translation = false;
    }
  end

  let create word translation notes = { word; translation; notes }
  let format { word; translation; notes } =
    let f notes = " − " ^ notes in
    word ^ ": " ^ translation ^ (Option.value ~default:"" (Option.map ~f notes))

  let order_elems swap_translation = if swap_translation then Tuple2.swap else Fn.id

  let to_list ?(options=FormatOptions.defaults) { word; translation; notes = maybe_notes } =
    let open FormatOptions in
    let (first_elem, second_elem) = order_elems options.swap_translation (word, translation) in
    match (maybe_notes, options.merge_notes) with
    | _, false -> [first_elem; second_elem; Option.value ~default:"" maybe_notes]
    | Some notes, true -> [first_elem; second_elem ^ options.merge_with ^ notes]
    | None, true -> [first_elem; second_elem]

  let make_headers options =
    let open FormatOptions in
    let (first_elem, second_elem) = order_elems options.swap_translation ("Word", "Translation") in
    if options.merge_notes
      then [first_elem; second_elem]
      else [first_elem; second_elem; "Notes"]
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

let max_weight = 100000
let weight_multiple = 5

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
  let f w = if w >= max_weight then w else w * weight_multiple in
  modify_weight t record ~f

let decrease_weight t record =
  let f w = if w <= 1 then 1 else w / weight_multiple in
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
  let get_weight i elem =
    let weight_opt = Hashtbl.find weights elem.Record.word in
    let weight = Option.value_map ~f:Int.to_float ~default:1. weight_opt in
    (* NOTE: add weight to recent words *)
    weight +. (Int.to_float i)
  in
  let weights = List.mapi records ~f:get_weight in
  let cdf_f (v, acc) elem = let sum = v +. elem in (sum, sum :: acc) in
  let (sum, cum_weights) = List.fold ~init:(0., []) ~f:cdf_f weights in
  let cdf_probs = List.rev_map ~f:(fun v -> v /. sum) cum_weights in
  let random_value = Random.float 1. in
  let res = List.findi ~f:(fun _i v -> random_value <= v) cdf_probs in
  let index = Option.map ~f:fst res in
  Option.bind ~f:(List.nth records) index

let get_top_n { records; weights; } n =
  let get_weight elem =
    let weight_opt = Hashtbl.find weights elem.Record.word in
    Option.value ~default:1 weight_opt
  in
  let compare r1 r2 = - Int.compare (get_weight r1) (get_weight r2) in
  List.take (List.sort ~compare records) n

let records { records; _ } = records
