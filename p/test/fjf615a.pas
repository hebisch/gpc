program fjf615a;

var
  s: String (42);

begin
  s.Capacity := 0;  { WRONG }
  WriteLn ('failed')
end.
