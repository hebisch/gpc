program fjf1045c (Output);

type
  t (n: Integer) = array [1 .. n] of Integer;
  u (a, b, c: Integer) = array [a .. b] of Integer;

procedure q1 (a, b: t; c, d: u; e, f: String);
begin
end;

procedure q2 (protected a, b: t; protected c, d: u; protected e, f: String);
begin
end;

procedure q3 (var a, b: t; var c, d: u; var e, f: String);
begin
end;

procedure q4 (protected var a, b: t; protected var c, d: u; protected var e, f: String);
begin
end;

procedure q5 (const a, b: t; const c, d: u; const e, f: String);
begin
end;

{$extended-pascal}

procedure p (n: Integer);
var
  a: t (42);
  b: t (n);
  c: u (n, 2 * n, Sqr (n));
  d: u (n, 2 * n, Sqr (n - 84));
  e: String (40);
  f: String (n - 2);
  g: String (n);
begin
  e := 'abc';
  f := 'x';
  g := 'def';
  q1 (a, b, c, d, e, g);
  q2 (a, b, c, d, e, g);
  q3 (a, b, c, d, e, f);
  q4 (a, b, c, d, e, f);
  q5 (a, b, c, d, e, g);
  WriteLn ('OK')
end;

begin
  p (42)
end.
