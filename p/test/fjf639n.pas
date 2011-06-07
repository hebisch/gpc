program fjf639n;

type
  t = object end;
  u = object end;

var
  v: ^t;

begin
  {$W-}
  if v^ is t then WriteLn ('OK') else WriteLn ('failed')
end.
