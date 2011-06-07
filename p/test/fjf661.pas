program fjf661;

type
  a = Integer;
  b = a (42);  { WRONG }

begin
  WriteLn ('failed')
end.
