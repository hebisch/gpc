program fjf1041c (Output);

type
  t = String (10);

operator and (const a, b: String) = c: t;
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
  if (a and b = 'abc-def')
     and (a and c = 'abc-g')
     and (a and d = 'abc-h')
     and (a and e = 'abc-ijk')
     and (c and a = 'g-abc')
     and (c and c = 'g-g')
     and (c and d = 'g-h')
     and (c and e = 'g-ijk')
     and (d and a = 'h-abc')
     and (d and c = 'h-g')
     and (d and d = 'h-h')
     and (d and e = 'h-ijk')
     and (e and a = 'ijk-abc')
     and (e and c = 'ijk-g')
     and (e and d = 'ijk-h')
     and (e and e = 'ijk-ijk')
     and ((a + d) and (b + c) = 'abch-defg') then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
