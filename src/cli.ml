open Core

let show_command =
  let open Command.Let_syntax in
  Command.basic
  ~summary:"Shows a single flashcard."
  ~readme:(fun _ -> "Only one of the three flags must be provided")
  [%map_open
    let choice = choose_one ~if_nothing_chosen:`Raise
      [ flag "-translation" (optional string)
        ~aliases:["-t"] ~doc:"translation of the card to show"
      |> map ~f:(Option.map ~f:(fun v -> `Translation v))
      ; flag "-word" (optional string)
        ~aliases:["-w"] ~doc:"word of the card to show"
      |> map ~f:(Option.map ~f:(fun v -> `Word v))
      ; flag "-random" no_arg
        ~aliases:["-r"] ~doc:"random card"
      |> map ~f:(fun v -> Option.some_if v `Random)
    ]
    in
    fun () -> Commands.show (Config.load ()) choice
  ]

let quiz_command =
  let open Command.Let_syntax in
  Command.basic
  ~summary:"Runs a quiz"
  ~readme:(Fn.const "The types of quiz are 'guess-word' and 'guess-translation'")
  [%map_open
    let quiz_type = anon ("type" %: Quiz.QuizType.arg) in
    fun () -> Commands.quiz (Config.load ()) quiz_type
  ]

let init_command =
  let open Command.Let_syntax in
  Command.basic
  ~summary:"Initialize flashcards"
  (return Commands.init)

let search_command =
  let open Command.Let_syntax in
  Command.basic
  ~summary:"Search for a word"
  [%map_open
    let word = anon ("word" %: string) in
    fun () -> Commands.search (Config.load ()) word
  ]

let top_n_command =
  let open Command.Let_syntax in
  Command.basic
  ~summary:"Shows top words most missed"
  [%map_open
    let n = flag "-n" (optional_with_default 5 int) ~doc:"number of words to show" in
    fun () -> Commands.top_n (Config.load ()) n
  ]

let export_command =
  let open Command.Let_syntax in
  Command.basic
  ~summary:"Export the vocabulary in the given format"
  [%map_open
    let filename = anon ("filename" %: string) and
        no_headers = flag "-no-headers" no_arg ~doc:"do not include headers" in
    fun () -> Commands.export_vocabulary ~headers:(not no_headers) (Config.load ()) filename
  ]

let reset_weights_command =
  let open Command.Let_syntax in
  Command.basic
  ~summary:"Reset flashcards weights"
  (return Commands.reset_weights)

let flashcards_command =
  Command.group ~summary:"CLI based flashcards" [
    ("show", show_command);
    ("quiz", quiz_command);
    ("init", init_command);
    ("reset-weights", reset_weights_command);
    ("search", search_command);
    ("top-n", top_n_command);
    ("export", export_command);
  ]

let run () =
  Random.self_init ();
  Command.run ~build_info:"" ~version:"0.1" flashcards_command
