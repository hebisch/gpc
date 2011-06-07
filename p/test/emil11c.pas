program Emil11c (Output);

const
  Bar = 1 / Sqrt (16);

procedure Baz;
type
  t = array [1 .. Round (1 / Bar)] of Integer;
var
  v: array [1 .. Round (1000 * Bar)] of Integer;
begin
  if (Low (t) <> 1) or (High (t) <> 4) or
     (Low (v) <> 1) or (High (v) <> 250) then
    WriteLn ('Failed ', Low (t), ' ', High (t), ' ', Low (v), ' ', High (v))
  else
    WriteLn ('OK')
end;

begin
  Baz
end.
