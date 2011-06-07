program fsc14;
{string read}
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
   for i:=1 to 20 do
      s20[i]:=Chr(Ord('a')+i-1);
   {writing an elementoutside the string}
   i:=21;
   Write(s20[i])
end.
