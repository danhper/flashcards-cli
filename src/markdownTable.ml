open Core

module Parser: VocabularyIo.Parser = struct
  let parse_records markdown =
    let transform_line line = 
      let get_notes notes = if notes = "" then None else Some notes in
      match List.map ~f:String.strip (String.split ~on:'|' line) with
      | [word; translation] ->
        Some (Vocabulary.Record.create word translation None)
      | [word; translation; notes] ->
        Some (Vocabulary.Record.create word translation (get_notes notes))
      | _ -> None
    in
    String.split_lines markdown
    |> List.drop_while ~f:(Fn.compose String.is_empty String.strip)
    |> (Fn.flip List.drop) 2
    |> List.map ~f:transform_line
    |> List.filter_map ~f:Fn.id
end

module Io: VocabularyIo.S = VocabularyIo.Make(Parser)
