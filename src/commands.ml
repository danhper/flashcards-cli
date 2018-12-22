open Core

let show_record opt_record = match opt_record with
  | Some record -> Out_channel.print_endline (Vocabulary.Record.format record)
  | None -> Out_channel.prerr_endline "no record found"

let load_vocabulary config =
  let vocab_path = Config.vocabulary_path config in
  Vocabulary.from_file vocab_path (module MarkdownTable.Parser)

let show_command config choice =
  let vocabulary = load_vocabulary config in
  match choice with
  | `Translation tr -> show_record (Vocabulary.search_by_translation vocabulary tr)
  | `Word w -> show_record (Vocabulary.search_by_word vocabulary w)
  | `Random -> show_record (Vocabulary.random_record vocabulary)

let quiz_command config quiz_type =
  let vocabulary = load_vocabulary config in
  Quiz.run_quiz vocabulary quiz_type
