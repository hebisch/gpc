program fjf681c;

type
  t = (b, c);

var
  a: t = b;

begin
  a := t (Conjugate (a));  { WRONG }
  WriteLn ('failed')
end.
