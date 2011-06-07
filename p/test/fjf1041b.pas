program fjf1041b (Output);

type
  t = String (10);

operator foo (const a, b: String) = c: t;
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
  if (a foo b = 'abc-def')
     and (a foo c = 'abc-g')
     and (a foo d = 'abc-h')
     and (a foo e = 'abc-ijk')
     and (c foo a = 'g-abc')
     and (c foo c = 'g-g')
     and (c foo d = 'g-h')
     and (c foo e = 'g-ijk')
     and (d foo a = 'h-abc')
     and (d foo c = 'h-g')
     and (d foo d = 'h-h')
     and (d foo e = 'h-ijk')
     and (e foo a = 'ijk-abc')
     and (e foo c = 'ijk-g')
     and (e foo d = 'ijk-h')
     and (e foo e = 'ijk-ijk')
     and ((a + d) foo (b + c) = 'abch-defg') then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end.
