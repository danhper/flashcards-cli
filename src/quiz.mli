module QuizType: sig
  type t = GuessWord | GuessTranslation
  val of_string: String.t -> t
end

val run_quiz: Vocabulary.t -> QuizType.t -> unit
