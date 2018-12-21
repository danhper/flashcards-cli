open Core

let vocab_path = "/home/daniel/Dropbox/notes/german/vocabulary.md"

let show_record opt_record = match opt_record with
  | Some record -> Out_channel.print_endline (Vocabulary.Record.format record)
  | None -> Out_channel.prerr_endline "no record found"

let show_command choice =
  let vocabulary = Vocabulary.from_file vocab_path (module MarkdownTable.Parser) in
  match choice with
  | `Translation tr -> show_record (Vocabulary.search_by_translation vocabulary tr)
  | `Word w -> show_record (Vocabulary.search_by_word vocabulary w)
  | `Random -> show_record (Vocabulary.random_record vocabulary)
