open Core

let show_command =
  let open Command.Let_syntax in
  Command.basic
  ~summary:"Shows a single flashcard. Only one of the three options must be provided"
  [%map_open
    let choice = choose_one ~if_nothing_chosen:`Raise
      [ flag "-translation" (optional string)
        ~aliases:["-t"] ~doc:"the translation of the card to show"
      |> map ~f:(Option.map ~f:(fun v -> `Translation v))
      ; flag "-word" (optional string)
        ~aliases:["-w"] ~doc:"the word of the card to show"
      |> map ~f:(Option.map ~f:(fun v -> `Word v))
      ; flag "-random" no_arg
        ~aliases:["-r"] ~doc:"shows a random card"
      |> map ~f:(fun v -> Option.some_if v `Random)
    ]
    in
    fun () -> Commands.show_command (Config.load ()) choice
  ]

let quiz_command =
  let open Command.Let_syntax in
  Command.basic
  ~summary:"Runs a quiz"
  [%map_open
    let quiz_type = anon ("type" %: (Arg_type.create Quiz.QuizType.of_string)) in
    fun () -> Commands.quiz_command (Config.load ()) quiz_type
  ]

let flashcards_command =
  Command.group ~summary:"CLI based flashcards" [
    ("show", show_command);
    ("quiz", quiz_command);
  ]

let run () =
  Random.self_init ();
  Command.run ~build_info:"" ~version:"0.1" flashcards_command
