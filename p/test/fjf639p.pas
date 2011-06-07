program fjf639p;

type
  t = object end;
  u = object end;

var
  v: ^t;

begin
  {$W-}
  with v^ as t do
    WriteLn ('OK')
end.
