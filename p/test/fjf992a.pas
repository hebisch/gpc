{ Out of range in `Val' -> catch via 3rd parameter }

program fjf992a;

var
  a: 1 .. 10;
  b: Integer;

begin
  Val ('42', a, b);
  if b = 2 then WriteLn ('OK') else WriteLn ('failed')
end.
