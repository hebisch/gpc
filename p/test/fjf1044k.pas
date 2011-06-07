program fjf1044k;

type
  t (n: Integer) = array [1 .. n] of Integer;

var
  a: t (42);
  b: t (43);

begin
  a := b  { WRONG }
end.
