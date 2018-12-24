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

module Weights: sig
  type t

  val to_json: t -> Yojson.Safe.json
  val of_json: Yojson.Safe.json -> t Option.t
end

val empty: t
val create: ?weights:Weights.t -> Record.t List.t -> t
val size: t -> int
val weights: t -> Weights.t
val search_by_word: t -> String.t -> Record.t Option.t
val search_by_translation: t -> String.t -> Record.t Option.t
val random_record: t ->  Record.t Option.t
val increase_weight: t -> Record.t -> unit
val decrease_weight: t -> Record.t -> unit
