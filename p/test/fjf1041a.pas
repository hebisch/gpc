program fjf1041a (Output);

type
  t = String (10);

operator - (const a, b: String) = c: t;
begin
  c := a + '-' + b
end;

var
  a: t = 'abc';
  b: t = 'def';
  c: Char = 'g';

const
  d = 'h';
  e = 'ijk';

begin
  if (a - b = 'abc-def')
     and (a - c = 'abc-g')
     and (a - d = 'abc-h')
     and (a - e = 'abc-ijk')
     and (c - a = 'g-abc')
     and (c - c = 'g-g')
     and (c - d = 'g-h')
     and (c - e = 'g-ijk')
     and (d - a = 'h-abc')
     and (d - c = 'h-g')
     and (d - d = 'h-h')
     and (d - e = 'h-ijk')
     and (e - a = 'ijk-abc')
     and (e - c = 'ijk-g')
     and (e - d = 'ijk-h')
     and (e - e = 'ijk-ijk')
     and ((a + d) - (b + c) = 'abch-defg') then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
