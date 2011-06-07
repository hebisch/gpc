{ FLAG --mixed-comments -Wmixed-comments }

Program MixCom7;

{$W-}
{ This is a mixed comment. *)
begin
(* So is this one. }
{$W+}
  writeln ( 'OK' );
end.
