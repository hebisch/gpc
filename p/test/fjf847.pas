program fjf847;

var
  v: array [1 .. 10] of Char = '';

begin
  if v[10] = ' ' then WriteLn ('OK') else WriteLn ('failed ', Ord (v[10]))
end.
