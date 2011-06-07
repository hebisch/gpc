program mir041iu;
{local initializer out of bounds}
uses GPC;
type range = 10..42;
var k : Integer;

procedure Local (parm: Integer);
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
   k := 51;
   Local (k);
end.
