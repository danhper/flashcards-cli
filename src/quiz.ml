open Core

module QuizType = struct
  type t = GuessWord | GuessTranslation
  let of_string str = match str with
  | "guess-word" -> GuessWord
  | "guess-translation" -> GuessTranslation
  | _ -> failwith "only 'guess-word' and 'guess-translation' available"
end

let rec run_quiz vocabulary quiz_type =
  let open QuizType in
  let open Vocabulary.Record in

  let record = Option.value_exn (Vocabulary.random_record vocabulary) in
  let (question, answer) = match quiz_type with
  | GuessWord -> (record.translation, record.word)
  | GuessTranslation -> (record.word, record.translation)
  in
  let answer_tokens = String.split ~on:' ' answer in

  Out_channel.printf "%s: " question;
  Out_channel.flush Out_channel.stdout;

  match In_channel.input_line In_channel.stdin with
  | None -> ()
  | Some user_answer ->
    if String.Caseless.equal answer user_answer ||
       List.exists ~f:(String.Caseless.equal user_answer) answer_tokens
      then Out_channel.print_endline ("✔ " ^ (format record))
      else Out_channel.print_endline ("✗ " ^ (format record));
    Out_channel.newline Out_channel.stdout;
    run_quiz vocabulary quiz_type
