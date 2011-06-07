program mir031b;
{procedure `or' with range}
uses GPC;
type range = 20000000008..20000000016;
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
   a := 20000000008;
   or (a, 20000000016);
   { `or' can't underflow ... we test only going over upper bound }
end.
