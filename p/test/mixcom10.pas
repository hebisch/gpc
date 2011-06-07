{ FLAG --no-mixed-comments -Wmixed-comments }

Program MixCom10;

{$W-}

{ This is a (* non-mixed *) comment. }
begin
(* So is { this } one. *)
  writeln ( 'OK' );
end.
