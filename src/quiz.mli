open Core

module QuizType: sig
  type t = GuessWord | GuessTranslation
  val of_string: String.t -> t
  val arg: t Command.Arg_type.t
end

val run_quiz: Vocabulary.t -> QuizType.t -> unit
