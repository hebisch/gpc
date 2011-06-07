program fjf521e;

type
  t = Text;
  p = procedure (a: t);  { WRONG }

begin
  WriteLn ('failed')
end.
