program fjf915p;

type
  t (n: Integer) = Integer;

var
  a: ^t;

function and_then (i: Integer): Integer;
begin
  and_then := i
end;

begin
  New (a, and_then (2));
  Dispose (a, and_then (2));
  WriteLn ('OK')
end.
