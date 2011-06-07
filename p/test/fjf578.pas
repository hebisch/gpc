program fjf578;

var
  Called: Integer = 0;

function foo: Integer;
begin
  Inc (Called);
  foo := 42
end;

begin
  if not (foo in [1 .. 10, 40 .. 50, 80 .. 90]) then
    WriteLn ('failed 1')
  else if Called <> 1 then
    WriteLn ('failed 2 ', Called)
  else
    WriteLn ('OK')
end.
