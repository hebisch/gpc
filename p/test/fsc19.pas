program fsc19;
{function chr }
uses GPC;
type Result =  array [0..259]of Char;
var r : Result;
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
end; { ExpectError }
begin
   AtExit(ExpectError);
   {chr is only for integer 1..255}
   for i:= 0 to 259 do
      r[i]:=Chr(i)
end.
