program fjf275;

type
  x (a : integer) = packed array [1..1000] of 0..a;

var
  i : integer;
  v : ^x;
begin
  i := 42;
  New (v, i);
  if v^.a = 42 then writeln ('OK') else writeln ('Failed')
end.
