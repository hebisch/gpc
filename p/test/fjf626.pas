program fjf626;

const
  a: set of -2 .. 10 = [2, 5, -1, 10];

var
  b: set of -100 .. 100 = [2, 5, -1, 10];

type
  c = set of -42 .. 128;

begin
  if (Low (a) <> -2) or (High (a) <> 10) then
    WriteLn ('failed a ', Low (a), ' ', High (a))
  else if (Low (b) <> -100) or (High (b) <> 100) then
    WriteLn ('failed b ', Low (b), ' ', High (b))
  else if (Low (c) <> -42) or (High (c) <> 128) then
    WriteLn ('failed c ', Low (c), ' ', High (c))
  else
    WriteLn ('OK')
end.
