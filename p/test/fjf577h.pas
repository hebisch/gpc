program fjf577h;

var
  a: 'e' ..'g' = 'f';
  b: set of Char;

begin
  b := ['a' .. a];
  if b = ['a' .. 'f'] then WriteLn ('OK') else WriteLn ('failed')
end.
