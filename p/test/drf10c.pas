{ BUG: Global variables initialized by a function call.
  Should this be a compile-time failure? EP doesn't allow it.
  Otherwise, of course, bar must be called only once. }

program drf10c;

function bar : Integer;
var b : Boolean = False; attribute (static);
begin
  if b then
    begin
      WriteLn ('failed 1');
      Halt
    end;
  b := True;
  bar := 42
end;

var
  foo: Integer = bar;

begin
  if foo = foo then WriteLn ('OK') else WriteLn ('failed 2')
end.
