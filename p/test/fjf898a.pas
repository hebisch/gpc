{ GPC doesn't detect the wrong initializer because it's not evaluated.
  Declaring a variable of type b causes a correct error message. }

program fjf898;

type
  a (n: Integer) = array [3 .. n] of Integer value (1, 2, 3);
  b = a (4);  { WRONG }

begin
end.
