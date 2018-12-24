type t

val dir: String.t
val config_path: String.t
val weights_path: String.t
val create: String.t -> t
val from_file: String.t -> t
val to_file: t -> String.t -> unit
val vocabulary_path: t -> String.t
val load: unit -> t
val save: t -> unit