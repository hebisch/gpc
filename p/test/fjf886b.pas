program fjf886b;

type x (n : Integer) = array [1 .. n] of Integer value (n, 42);

var y : x (1);  { WRONG }

begin
end.
