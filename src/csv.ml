open Core

module Formatter: VocabularyIo.Formatter = struct
  let format_records ?(options=VocabularyIo.FormatterOptions.defaults) records =
    let rows =
      if options.headers
        then [Vocabulary.Record.make_headers options.record_options |> String.concat ~sep:","]
        else []
    in
    let quote_string string =
      if List.exists [','; '"'; '\n'] ~f:(String.contains string) then
        let escaped = String.substr_replace_all ~pattern:"\"" ~with_:"\"\"" string in
        "\"" ^ escaped ^ "\""
      else string
    in
    let format_record record =
      let row = Vocabulary.Record.to_list ~options:options.record_options record in
      String.concat ~sep:"," (List.map ~f:quote_string row)
    in
    String.concat ~sep:"\n" (rows @ (List.map ~f:format_record records))
end

module Out: VocabularyIo.Out = VocabularyIo.MakeOut(Formatter)
