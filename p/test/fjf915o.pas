program fjf915o;

type
  t (n: Integer) = Integer;

var
  a: ^t;

const
  Exit = 42;

begin
  New (a, Exit);
  Dispose (a, Exit);
  WriteLn ('OK')
end.
