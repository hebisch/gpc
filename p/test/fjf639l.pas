program fjf639l;

type
  t = object end;
  u = object end;

var
  v: ^t;

begin
  with v^ as u do  { WRONG }
    WriteLn ('failed')
end.
