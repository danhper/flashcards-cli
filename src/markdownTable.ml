open Core

module Parser: VocabularyIo.Parser = struct
  let parse_records markdown =
    let transform_line line = 
      let get_notes notes = if String.(notes = "") then None else Some notes in
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
  let format_records ?(options=VocabularyIo.FormatterOptions.defaults) records =
    let lines =
      if options.headers then
        let headers = Vocabulary.Record.make_headers options.record_options in
        let sep = List.map ~f:(fun s -> String.make (String.length s) '-') headers in
        [String.concat ~sep:" | "  headers; String.concat ~sep:"-|-" sep]
        else []
    in
    let format_record record =
      let row = Vocabulary.Record.to_list ~options:options.record_options record in
      String.concat ~sep:" | " row
    in
    String.concat ~sep:"\n" (lines @ (List.map ~f:format_record records))
end

module In: VocabularyIo.In = VocabularyIo.MakeIn(Parser)
module Out: VocabularyIo.Out = VocabularyIo.MakeOut(Formatter)
