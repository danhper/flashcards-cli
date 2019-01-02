open Core

let init () =
  Unix.mkdir_p ~perm:0o755 Config.dir;
  Out_channel.printf "vocabulary path: ";
  Out_channel.flush Out_channel.stdout;
  match In_channel.input_line In_channel.stdin with
  | Some filepath -> Config.save (Config.create filepath)
  | None -> Out_channel.prerr_endline "could not read vocabulary path"

let reset_weights () =
  if Sys.file_exists_exn Config.weights_path
    then Unix.unlink Config.weights_path

let show_record opt_record = match opt_record with
  | Some record -> Out_channel.print_endline (Vocabulary.Record.format record)
  | None -> Out_channel.prerr_endline "no record found"

let load_vocabulary config =
  let vocab_path = Config.vocabulary_path config in
  MarkdownTable.Io.from_file vocab_path

let show config choice =
  let vocabulary = load_vocabulary config in
  match choice with
  | `Translation tr -> show_record (Vocabulary.search_by_translation vocabulary tr)
  | `Word w -> show_record (Vocabulary.search_by_word vocabulary w)
  | `Random -> show_record (Vocabulary.random_record vocabulary)

let quiz config quiz_type =
  let vocabulary = load_vocabulary config in
  Quiz.run_quiz vocabulary quiz_type

let search config word =
  match Config.search_url config with
  | None | Some "" ->
    Out_channel.prerr_endline "no search_url configured"
  | Some base_url ->
    let url = String.substr_replace_first base_url ~pattern:"$word" ~with_:word in
    Util.open_url url
