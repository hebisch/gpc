{$extended-pascal}

program fjf1045p (Output);

type
  t (n: Integer) = array [1 .. n] of Integer;

var
  a: t (42);

procedure p (a, b: t);
begin
end;

begin
  p (a, 42)  { WRONG }
end.
