program fjf1044a;

type
  t (n: Integer) = array [1 .. n] of Integer;
  u (a, b, c: Integer) = array [a .. b] of Integer;

procedure p (n: Integer);
var
  a: array [1 .. 10] of t (42);
  b: packed array [21 .. 30] of t (n);
  c: array [1 .. 10] of u (n, 2 * n, Sqr (n));
  d: packed array [21 .. 30] of u (n, 2 * n, Sqr (n - 84));
  e: array [1 .. 10] of String (40);
  f: packed array [21 .. 30] of String (n - 2);
begin
  Pack (a, 1, b);
  Unpack (b, a, 1);
  Pack (c, 1, d);
  Unpack (d, c, 1);
  Pack (e, 1, f);
  Unpack (f, e, 1);
end;

begin
  p (42);
  WriteLn ('OK')
end.
