let open_url url =
  if Sys.command "which xdg-open > /dev/null 2>&1" = 0
    then ignore(Sys.command ("xdg-open " ^ url))
    else ignore(Sys.command ("open " ^ url))
