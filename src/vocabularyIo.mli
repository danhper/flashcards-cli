open Core

val save_weights: Vocabulary.t -> unit

module type Parser = sig
  val parse_records: String.t -> Vocabulary.Record.t List.t
end

module type S = sig
  val from_file: String.t -> Vocabulary.t
  val from_string: String.t -> Vocabulary.t
end

module Make (P: Parser): S
