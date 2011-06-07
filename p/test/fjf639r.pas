program fjf639r;

type
  t = object end;
  u = object (t) end;

var
  v: t;

begin
  {$W-}
  if not (v is u) then WriteLn ('OK') else WriteLn ('failed')
end.
