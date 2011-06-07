program mir032ab;
{procedure `xor' with range}
uses GPC;
type range = $100000000..$100000020;
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
   a := $100000010;
   xor (a, $000000100); { this should go over ubound }
end.
