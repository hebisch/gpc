program fjf915hh;

operator div (a, b: Real) = c: Real;
begin
  c := a / b
end;

var
  a: ^Integer;

begin
  New (a, div (1, 2))  { WRONG }
end.
