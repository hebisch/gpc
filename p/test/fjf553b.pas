program fjf553b;

var
  p: ^Integer;

begin
  New (p, 2);  { WRONG }
  WriteLn ('failed')
end.
