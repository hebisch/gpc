program mir032ba;
{procedure `xor' with range}
uses GPC;
type range = 8..12;
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
   xor (a, 8 or 4); { this should go bellow lbound }
end.
