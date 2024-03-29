open Core

let formatters = String.Map.of_alist_exn [
  ("csv", (module Csv.Out: VocabularyIo.Out));
  ("md", (module MarkdownTable.Out));
]

let init () =
  Core_unix.mkdir_p ~perm:0o755 Config.dir;
  match LNoise.linenoise "vocabulary path: " with
  | Some filepath -> Config.save (Config.create filepath)
  | None -> Out_channel.prerr_endline "could not read vocabulary path"

let reset_weights () =
  if Sys_unix.file_exists_exn Config.weights_path
    then Core_unix.unlink Config.weights_path

let show_record opt_record = match opt_record with
  | Some record -> Out_channel.print_endline (Vocabulary.Record.format record)
  | None -> Out_channel.prerr_endline "no record found"

let load_vocabulary config =
  let vocab_path = Config.vocabulary_path config in
  MarkdownTable.In.from_file vocab_path

let show config choice =
  let vocabulary = load_vocabulary config in
  match choice with
  | `Translation tr -> show_record (Vocabulary.search_by_translation vocabulary tr)
  | `Word w -> show_record (Vocabulary.search_by_word vocabulary w)
  | `Random -> show_record (Vocabulary.random_record vocabulary)

let export_vocabulary ~options config filename =
  let vocabulary = load_vocabulary config in
  let (_, ext) = Filename.split_extension filename in
  let output_module = Option.bind ~f:(Map.find formatters) ext in
  match output_module with
  | Some (module F) ->
    F.to_file ~options vocabulary filename
  | None ->
    let available_extesions = Map.keys formatters |> String.concat ~sep:", " in
    Out_channel.fprintf Out_channel.stderr
      "could not infer output format, filename must end with: %s\n" available_extesions

let top_n config n =
  let vocabulary = load_vocabulary config in
  let top_n = Vocabulary.get_top_n vocabulary n in
  List.iter ~f:(Fn.compose print_endline Vocabulary.Record.format) top_n

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
