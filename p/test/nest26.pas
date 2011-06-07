{$nested-comments,W nested-comments}

Program Nest26;

{ This is a { nested } comment. (WARN) }
begin
(* So is (* this *) one. *)
  writeln ( 'failed' );
end.
