open Core

module QuizType = struct
  type t = GuessWord | GuessTranslation
  let of_string str = match str with
  | "guess-word" -> GuessWord
  | "guess-translation" -> GuessTranslation
  | _ -> failwith "only 'guess-word' and 'guess-translation' available"

  let arg =
    let complete _env ~part =
      List.filter ["guess-word"; "guess-translation"] ~f:(String.is_prefix ~prefix:part)
    in
    Command.Arg_type.create ~complete of_string
end

let rec run_quiz vocabulary quiz_type =
  let open QuizType in
  let open Vocabulary.Record in

  let record = Option.value_exn (Vocabulary.random_record vocabulary) in
  let (question, answer) = match quiz_type with
  | GuessWord -> (record.translation, record.word)
  | GuessTranslation -> (record.word, record.translation)
  in

  let prompt = question ^ ": " in

  let normalize_token token =
    String.strip ~drop:(fun v -> v = '(' || v = ')') token
  in

  match LNoise.linenoise prompt with
  | None -> VocabularyIo.save_weights vocabulary
  | Some user_answer ->
    let ((=)) = String.Caseless.equal in
    let answer_tokens =
      String.split_on_chars ~on:[' '; ','] answer
      |> List.map ~f:normalize_token
      |> List.filter ~f:(fun token -> String.length token > 0)
    in
    let good_answer = answer = user_answer ||
                      List.exists ~f:((=) user_answer) answer_tokens in
    let (func, prefix) = if good_answer
                           then (Vocabulary.decrease_weight, "✔ ")
                           else (Vocabulary.increase_weight, "✗ ") in
    func vocabulary record;
    Out_channel.print_endline (prefix ^ (format record) ^ "\n");
    run_quiz vocabulary quiz_type
