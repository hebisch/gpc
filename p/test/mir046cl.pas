program mir046cl;
{type with char initializer out of bounds, lower}
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
   localProc ('b');
end.
