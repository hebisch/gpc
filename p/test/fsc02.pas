program fsc02;
{array write}
uses GPC;
{Normally, it's not interesting, fsc01 should have found this kind of runtime error }
var t : array[-1..2] of Real;
   i  : Integer;
procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end;
begin
   AtExit(ExpectError);
   i:=-2;
   {Write outside range, one before array}
   t[i]:=10.3;
end.
