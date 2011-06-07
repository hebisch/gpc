program fjf681a;

type
  t = (b, c);

var
  a: t = b;

begin
  a := t (+a);  { WRONG }
  WriteLn ('failed')
end.
