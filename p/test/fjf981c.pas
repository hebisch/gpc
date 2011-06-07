program fjf981c;

type
  TString = String (10);

operator & (a, b: Char) = r: TString;
begin
  r := a + b
end;

operator | (a, b: Char) = r: TString;
begin
  r := b + a
end;

begin
  if ('O' | 'K') = 'KO' then WriteLn ('O' & 'K') else WriteLn ('failed')
end.
