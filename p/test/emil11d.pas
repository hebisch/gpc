program Emil11d (Output);

const
  Bar = 1 / Sqrt (16);

function Foo: Real;
begin
  Foo := Bar
end;

procedure Baz;
type
  t = array [1 .. Round (1 / Bar)] of Integer;
var
  v: array [1 .. Round (1000 * Bar)] of Integer;
begin
  if (Low (t) <> 1) or (High (t) <> 4) or
     (Low (v) <> 1) or (High (v) <> 250) then
    WriteLn ('Failed 1 ', Low (t), ' ', High (t), ' ', Low (v), ' ', High (v))
  else
    WriteLn ('OK')
end;

begin
  if Round (1 / Foo) <> 4 then
    WriteLn ('Failed 2 ', Round (1 / Foo))
  else
    Baz
end.
