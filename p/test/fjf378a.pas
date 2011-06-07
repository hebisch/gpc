program fjf378a;

type
  e = (a, b, c);
  t = array [b .. High (e)] of Integer;

begin
  WriteLn ('failed ', Low (t) = 1)  { WRONG }
end.
