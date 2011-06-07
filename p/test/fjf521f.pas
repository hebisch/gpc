program fjf521f;

type
  t = file;
  p = procedure (a: t);  { WRONG }

begin
  WriteLn ('failed')
end.
