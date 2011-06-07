program fjf615g;

var
  s: String (42);

begin
  ReadStr ('', s.Capacity);  { WRONG }
  WriteLn ('failed')
end.
