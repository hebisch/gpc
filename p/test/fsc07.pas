program fsc07;
{packed array write}
uses GPC;
var t : packed array[-1..2] of Real;
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
   {Write outside range, one before packed array}
   t[i]:=10.3;
end.
