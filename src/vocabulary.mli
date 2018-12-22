open Core

module Record: sig
  type t = {
    word: String.t;
    translation: String.t;
    notes: String.t Option.t;
  }

  val create: String.t -> String.t -> String.t Option.t -> t
  val format: t -> String.t
end

type t

module type Parser = sig
  val parse: String.t -> t
end

val empty: t
val create: Record.t List.t -> t
val from_file: String.t -> (module Parser) -> t
val size: t -> int
val search_by_word: t -> String.t -> Record.t Option.t
val search_by_translation: t -> String.t -> Record.t Option.t
val random_record: t ->  Record.t Option.t
