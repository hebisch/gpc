program mir046lu;
{type with longint initializer out of bounds, upper}
uses GPC;

procedure localProc (parm: LongInt);
type Foo = 200000000012..200000000042 Value parm;
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
   localProc (200000000043);
end.
