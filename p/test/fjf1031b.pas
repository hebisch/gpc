program fjf1031b (Output);

type
  t (n: Integer) = array [1 .. n] of Integer Value [3: 42; otherwise 7];

var
  a: ^t;

begin
  New (a, 2)  { WRONG }
end.
