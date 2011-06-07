program fjf588k;

type
  e = (e1, e2, e3, e4, e5, e6, e7);
  t (d: e) = array [e3 .. d] of Integer;

var
  a: t (e6);

begin
  if (Low (a) = Succ (e1, 2)) and (High (a) = Pred (e7)) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
