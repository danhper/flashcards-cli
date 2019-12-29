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

module Formatter: VocabularyIo.Formatter = struct
  let format_records ?(headers=true) records =
    let open Vocabulary.Record in
    let lines = if headers then [
      "German | Translation | Notes";
      "-------|-------------|------";
    ] else [] in
    let format_record record =
      let row = [record.word; record.translation; Option.value ~default:"" record.notes] in
      String.concat ~sep:" | " row
    in
    String.concat ~sep:"\n" (lines @ (List.map ~f:format_record records))
end

module In: VocabularyIo.In = VocabularyIo.MakeIn(Parser)
module Out: VocabularyIo.Out = VocabularyIo.MakeOut(Formatter)
