{$mixed-comments, W mixed-comments}

Program MixCom12;

{$W-}
{ This is a mixed comment. *)
begin
(* So is this one. }
{$W+}
  writeln ( 'OK' );
end.
