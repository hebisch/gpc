program mir032aa;
{procedure `xor' with range}
uses GPC;
type range = 8..16;
var  a : range;

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
   a := 8;
   xor (a, 16); { this should go over ubound }
end.
