program fjf577l;

type
  s = set of Char;

var
  v: s = ['a' .. 'e'];

begin
  if v = ['a' .. 'e'] then WriteLn ('OK') else WriteLn ('failed')
end.
