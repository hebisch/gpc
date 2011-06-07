program mir046cu;
{type with char initializer out of bounds, upper}
uses GPC;

procedure localProc (parm: Char);
type Foo = 'c'..'f' Value parm;
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
   localProc ('g');
end.
