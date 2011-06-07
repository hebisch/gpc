program mir041ll;
{local initializer out of bounds}
uses GPC;
type range = 200000000010..200000000042;
var k : LongInt;

procedure Local (parm: LongInt);
var ch : range Value parm;
begin
end;

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
   k := 200000000007;
   Local (k);
end.
