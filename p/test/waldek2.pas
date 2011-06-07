{ FLAG --nested-comments }

program nn;
{ Can NOT compile with --nested-comments (unless -Wcomment (or -Wall) is also given) }
begin
(* (* *) *)
  WriteLn ('OK')
end.
