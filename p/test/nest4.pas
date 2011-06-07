{ FLAG --nested-comments }

Program Nest4;

{ This is a { nested } comment. }

(* So is (* this *) one. *)

begin
  writeln ( 'OK' );
end.
