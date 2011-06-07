program fjf576h;

var
  a: 'e' ..'g' = 'f';
  b: set of Char;

begin
  b := ['a', a];
  if b = ['f', 'a'] then WriteLn ('OK') else WriteLn ('failed')
end.
