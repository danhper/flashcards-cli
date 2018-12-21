open Core

let show_flashcard_command =
  let open Command.Let_syntax in
  Command.basic
  ~summary:"Shows a single flashcard. Only one of the three options must be provided"
  [%map_open
    let translation = flag "-translation" (optional string) ~doc:"the translation of the card to show"
    and word = flag "-word" (optional string) ~doc:"the word of the card to show"
    and random = flag "-random" no_arg ~doc:"shows a random card" in
    fun () -> Commands.show_command translation word random
  ]


let run () =
  Random.self_init ();
  Command.run ~build_info:"" ~version:"0.1" show_flashcard_command
