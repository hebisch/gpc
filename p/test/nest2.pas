{ FLAG --nested-comments }

{$no-nested-comments}

Program Nest2;

{ This is a { non-nested comment. }

(* So is (* this one. *)

begin
  writeln ( 'OK' );
end.
