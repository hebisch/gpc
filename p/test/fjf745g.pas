program fjf745g;

type
  t (c: Char) = Integer;
  d = t ('');  { WRONG }

begin
  WriteLn ('failed')
end.
