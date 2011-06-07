program fjf576l;

type
  s = set of Char;

var
  v: s = ['a'];

begin
  if v = ['a'] then WriteLn ('OK') else WriteLn ('failed')
end.
