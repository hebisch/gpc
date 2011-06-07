{ FLAG --nested-comments -Wnested-comments }

Program Nest24;

{ This is a { nested } comment. (WARN) }
begin
(* So is (* this *) one. *)
  writeln ( 'failed' );
end.
