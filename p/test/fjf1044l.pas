program fjf1044l;

type
  u (a, b, c: Integer) = array [a .. b] of Integer;
  tc = u (42, 84, Sqr (42));

function f (n: Integer): tc;
var d: u (n, 2 * n, Sqr (n - 84));
begin
  d[n] := 42;
  Write ('O');
  f := d
end;

function g (n: Integer) = r: tc;
var d: u (n, 2 * n, Sqr (n - 84));
begin
  d[n] := 17;
  Write ('K');
  r := d
end;

function h (n: Integer): tc;
var d: u (n, 2 * n, Sqr (n - 84));
begin
  d[n] := 99;
  WriteLn;
  Return d
end;

begin
  if f (42) [42] <> 42 then WriteLn ('failed 1');
  if g (42) [42] <> 17 then WriteLn ('failed 2');
  if h (42) [42] <> 99 then WriteLn ('failed 3');
end.
