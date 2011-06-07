program mir032bb;
{procedure `xor' with range}
uses GPC;
type range = $100000001..$100000020;
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
   xor (a, $000000010); { this should go bellow lbound }
end.
