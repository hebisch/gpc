{$no-mixed-comments, W mixed-comments}

Program MixCom15;

{$W-}

{ This is a (* non-mixed *) comment. }
begin
(* So is { this } one. *)
  writeln ( 'OK' );
end.
