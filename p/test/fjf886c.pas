program fjf886c;

type x (n : Integer) = array [1 .. n] of Integer value (n + 2, 42);

var y : x (2);

begin
  if (y.n = 2) and (y[1] = 4) and (y[2] = 42)
    then WriteLn ('OK')
    else WriteLn ('failed ', y.n, ' ', y[1], ' ', y[2])
end.
