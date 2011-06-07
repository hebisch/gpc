program fjf588h;

type
  t (d: char) = array ['K' .. Succ (d)] of Integer;

var
  a: t ('N');

begin
  WriteLn (High (a), Low (a))
end.
