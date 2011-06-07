program fjf588i;

type
  t (d: char) = array ['K' .. Chr (Ord (d) - 3)] of Integer;

var
  a: t ('R');

begin
  WriteLn (High (a), Low (a))
end.
