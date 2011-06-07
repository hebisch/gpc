program fjf998u (Output);

const
  a = ['0' .. '2', '4' .. '8'] + ['7' .. Succ ('9')];
  b = Card (a);

begin
  if b = 10 then WriteLn ('OK') else WriteLn ('failed ', b)
end.
