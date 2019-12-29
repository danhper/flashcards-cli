open Core

val save_weights: Vocabulary.t -> unit

module type Parser = sig
  val parse_records: String.t -> Vocabulary.Record.t List.t
end

module FormatterOptions: sig
  type t = {
    headers: bool;
    merge_notes: bool;
    merge_with: string;
  }
  val defaults: t
end

module type Formatter = sig
  val format_records: ?options:FormatterOptions.t -> Vocabulary.Record.t List.t -> String.t
end

module type In = sig
  val from_string: String.t -> Vocabulary.t
  val from_file: String.t -> Vocabulary.t
end

module type Out = sig
  val to_string: ?options:FormatterOptions.t -> Vocabulary.t -> String.t
  val to_file: ?options:FormatterOptions.t -> Vocabulary.t -> String.t -> unit
end

module MakeIn (In: Parser): In
module MakeOut (Out: Formatter): Out
