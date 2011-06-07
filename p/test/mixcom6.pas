{ FLAG --no-mixed-comments }

Program MixCom6;

{ This is a (* non-mixed *) comment. }
begin
(* So is { this } one. *)
  writeln ( 'OK' );
end.
