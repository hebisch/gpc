program fjf588l;

type
  e = (e1, e2, e3, e4, e5, e6, e7);
  t (d: Char) = array [e4 .. Succ (e2, Ord ('D') - Ord (d))] of Integer;

var
  a: t ('A');

begin
  if (Low (a) = Pred (e3, -1)) and (High (a) = Succ (e7, -2)) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
