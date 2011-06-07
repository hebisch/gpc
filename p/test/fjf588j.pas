program fjf588j;

type
  t (d: ShortCard) = array ['K' .. Chr (d + 13)] of Integer;

var
  a: t (Ord ('B'));

begin
  WriteLn (High (a), Low (a))
end.
