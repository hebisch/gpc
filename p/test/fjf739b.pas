program fjf739b;

type
  s (b: Integer) = Integer;
  d = s (42);

var
  c: d;

begin
  WriteLn ('failed ', c.b.b)  { WRONG }
end.
