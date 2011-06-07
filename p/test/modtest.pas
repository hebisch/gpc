program modtest;
var
  a: integer = 42;
type
  t(b:integer) = integer value b mod 4;
var
  b:t(99);
begin
  writeln(b);
end.

