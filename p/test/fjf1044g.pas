program fjf1044g;

type
  t (n: Integer) = array [1 .. n] of Integer;
  u (a, b, c: Integer) = array [a .. b] of Integer;

procedure p (n: Integer);
var
  a: t (42);
  b: t (n);
  c: u (n, 2 * n, Sqr (n));
  d: u (n, 2 * n, Sqr (n - 84));
  e: String (40);
  f: String (n - 2);
begin
  a := b;
  c := d;
  e := f
end;

begin
  p (42);
  WriteLn ('OK')
end.
