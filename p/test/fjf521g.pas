program fjf521g;

type
  t = file of Integer;
  p = procedure (a: t);  { WRONG }

begin
  WriteLn ('failed')
end.
