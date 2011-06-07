program fsc08;
{packed array read}
uses GPC;
var t : packed array[-1..2] of Integer;
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
   for i:=-1 to 2 do
      t[i]:=10;
   i:=3;
   {Read outside the range of packed array : one too far}
   WriteLn(t[i]);
end.
