program fjf575;

type
  TString = String (3);

function Int2Str (i: Integer) = s: TString;
begin
  Str (i, s)
end;

begin
  if Int2Str (42) = '42' then WriteLn ('OK') else WriteLn ('failed')
end.
