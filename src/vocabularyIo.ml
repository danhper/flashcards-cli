open Core

let save_weights vocab =
  let weights = Vocabulary.weights vocab in
  let json_weights = Vocabulary.Weights.to_json weights in
  Yojson.Safe.to_file Config.weights_path json_weights

let load_weights () =
  if Sys.file_exists_exn Config.weights_path
    then Vocabulary.Weights.of_json (Yojson.Safe.from_file Config.weights_path)
    else None

module type In = sig
  val from_string: String.t -> Vocabulary.t
  val from_file: String.t -> Vocabulary.t
end

module type Out = sig
  val to_string: ?headers:bool -> Vocabulary.t -> String.t
  val to_file: ?headers:bool -> Vocabulary.t -> String.t -> unit
end

module type Parser = sig
  val parse_records: String.t -> Vocabulary.Record.t List.t
end

module type Formatter = sig
  val format_records: ?headers:bool -> Vocabulary.Record.t List.t -> String.t
end

module MakeIn (P: Parser): In = struct
  let from_string records_string =
    let records = P.parse_records records_string in
    Vocabulary.create ?weights:(load_weights ()) records

  let from_file filepath = from_string (In_channel.read_all filepath)
end


module MakeOut (P: Formatter): Out = struct
  let to_string ?(headers=true) vocabulary = P.format_records ~headers (Vocabulary.records vocabulary)
  let to_file ?(headers=true) vocabulary filename =
    let data = to_string ~headers vocabulary in
    Out_channel.write_all ~data filename
end
