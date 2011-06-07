program fjf711;

var
  p: ^Integer;

begin
  GetMem (p, 1) := 3;  { WRONG }
  WriteLn ('failed')
end.
