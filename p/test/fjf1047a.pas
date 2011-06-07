program fjf1047a (Output);

type
  t = 'a' .. Chr (200);

var
  a: -200 .. 100;
  b: t;

begin
  for a := 97 to 100 do b := t (a);
  if b = Chr (100) then WriteLn ('OK') else WriteLn ('failed')
end.
