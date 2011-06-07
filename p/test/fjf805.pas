program fjf805;

function foo: Integer;
begin
  foo := 42
end;

var
  a: function: Integer = foo;

begin
  if (not a) = (not 42) then WriteLn ('OK') else WriteLn ('failed ', not a, ' ', not 42)
end.
