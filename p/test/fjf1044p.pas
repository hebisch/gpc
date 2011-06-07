program fjf1044p;

type
  u (a, b, c: Integer) = array [a .. b] of Integer;

procedure f (n: Integer);
var
  f: file of u (42, 84, Sqr (42));
  d: u (n, 2 * n, Sqr (n - 84));
begin
  Rewrite (f);
  d[50] := 42;
  Write (f, d);
  d[50] := 19;
  Reset (f);
  Read (f, d);
  if d[50] = 42 then WriteLn ('OK') else WriteLn ('failed ', d[50])
end;

begin
  f (42)
end.
