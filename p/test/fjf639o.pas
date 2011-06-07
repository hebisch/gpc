program fjf639o;

type
  t = object end;
  u = object end;

var
  v: ^t;

begin
  with v^ as t do  { WARN }
    WriteLn ('failed')
end.
