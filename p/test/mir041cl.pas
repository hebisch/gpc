program mir041cl;
{local initializer out of bounds}
uses GPC;
type range = 'c'..'j';
var k : Char;

procedure Local (parm: Char);
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
   k := 'a';
   Local (k);
end.
