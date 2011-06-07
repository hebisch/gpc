program mir031a;
{procedure `or' with range}
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
   or (a, 16);
   { `or' can't underflow ... we test only going over upper bound }
end.
