program fjf226t;

var
  p : ^integer = nil;

begin
  if true or_else (p^ in [1 .. 10]) then WriteLn ('OK')
end.
