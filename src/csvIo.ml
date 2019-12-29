open Core

module Formatter: VocabularyIo.Formatter = struct
  let format_records ?(headers=true) records =
    let open Vocabulary.Record in
    let rows = if headers then ["Word,Translation,Notes"] else [] in
    let quote_string string =
      if String.contains string ',' || String.contains string '"' then
        let escaped = String.substr_replace_all ~pattern:"\"" ~with_:"\"\"" string in
        "\"" ^ escaped ^ "\""
      else string
    in
    let format_record record =
      let row = [record.word; record.translation; Option.value ~default:"" record.notes] in
      String.concat ~sep:"," (List.map ~f:quote_string row)
    in
    String.concat ~sep:"\n" (rows @ (List.map ~f:format_record records))
end

module Out: VocabularyIo.Out = VocabularyIo.MakeOut(Formatter)
