program fsc01;
{array write}
uses GPC;
var t : array[1..2] of Integer;
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
   i:=3;
   {Write outside range of array, one too far}
   t[i]:=10;
end.
