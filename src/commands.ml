open Core

let vocab_path = "/home/daniel/Dropbox/notes/german/vocabulary.md"

let show_record opt_record = match opt_record with
  | Some record -> Out_channel.print_endline (Vocabulary.Record.format record)
  | None -> Out_channel.prerr_endline "no record found"

let show_command translation word random =
  let vocabulary = Vocabulary.from_file vocab_path (module MarkdownTable.Parser) in
  match (translation, word, random) with
  | Some tr, None, false -> show_record (Vocabulary.search_by_translation vocabulary tr)
  | None, Some w, false -> show_record (Vocabulary.search_by_word vocabulary w)
  | None, None, true -> show_record (Vocabulary.random_record vocabulary)
  | _ -> Out_channel.prerr_endline "only one of -translation, -word or -random should be passed"
