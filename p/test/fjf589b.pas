program fjf589b;

type
  x (n: Cardinal) = array [1 .. n] of Integer;

begin
  Writeln ('failed ', High (x))  { WRONG }
end.
