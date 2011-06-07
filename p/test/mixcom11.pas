{ FLAG --mixed-comments }

{$no-mixed-comments}

Program MixCom11;

{ This is a non-mixed *) comment. }
begin
(* So is this } one. *)
  writeln ( 'OK' );
end.
