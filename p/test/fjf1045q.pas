program fjf1045q (Output);

type
  t (n: Integer) = array [1 .. n] of Integer;
  u (n: Integer) = array [1 .. n] of Integer;
  t42 = t (42);

var
  b: u (42);

procedure p (a: t42);
begin
end;

begin
  p (b)  { WRONG }
end.
