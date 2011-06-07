program fjf639h;

type
  t = object end;
  u = object (t) end;

var
  v: ^t;

begin
  with v^ as Integer do  { WRONG }
    WriteLn ('failed')
end.
