program fjf1032a (Output);

type
  i42 = Integer value 42;

function f: i42;
begin
  Exit;
  f := 99
end;

begin
  if f = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
