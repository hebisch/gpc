program fjf886a;

type x (n : Integer) = Integer value 42;

var y : x (1);

begin
  if (y.n = 1) and (y = 42)
    then WriteLn ('OK')
    else WriteLn ('failed ', y.n, ' ', y)
end.
