program fjf615c;

var
  s: String (42);

begin
  Inc (s.Capacity);  { WRONG }
  WriteLn ('failed')
end.
