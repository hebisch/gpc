program mir046il;
{type with int initializer out of bounds, lower}
uses GPC;

procedure localProc (parm: Integer);
type Foo = 12..42 Value parm;
var a: Foo;
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
   localProc (11);
end.
