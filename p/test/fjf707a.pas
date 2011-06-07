program fjf707a;

var
  c: array ['a' .. 'c'] of Integer = (1, 2, 3);
  v: Char = 'b';
  i: Integer;

begin
  i := c[v];
  if i = 2 then WriteLn ('OK') else WriteLn ('failed ', i)
end.
