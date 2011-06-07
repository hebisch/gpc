program fjf1044s;

type
  t (n: Integer) = array [1 .. n] of Integer;
  u (a, b, c: Integer) = array [a .. b] of Integer;
  ta = t (42);
  tc = u (42, 84, Sqr (42));
  te = String (40);

procedure q1 (a: ta; c: tc; e: te);
begin
end;

procedure q2 (protected a: ta; protected c: tc; protected e: te);
begin
end;

procedure q3 (var a: ta; var c: tc; var e: te);
begin
end;

procedure q4 (protected var a: ta; protected var c: tc; protected var e: te);
begin
end;

procedure q5 (const a: ta; const c: tc; const e: te);
begin
end;

procedure p (n: Integer);
var
  b: t (n);
  d: packed array [1 .. 2] of u (n, 2 * n, Sqr (n - 84));
  f: String (n - 2);
begin
  q1 (b, d[1], f);
  q2 (b, d[1], f);
  q3 (b, d[1], f);
  q4 (b, d[1], f);
  q5 (b, d[1], f);
  WriteLn ('OK')
end;

begin
  p (42)
end.
