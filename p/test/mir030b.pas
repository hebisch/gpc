program mir030b;
{procedure `and' with range}
uses GPC;
type range = 20000000006..20000000012;
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
   a := 20000000006;
   and (a, 20000000010);
   { `and' can't overflow ... we test only going under lower bound }
end.
