program fsc13;
{string write}
Uses GPC;
var s20 : String[20];
   i    : Integer;
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
   {assigning too much char in a string}
   for i:=1 to 21 do
      s20[i]:=Chr(Ord('a')+i-1);
end.
