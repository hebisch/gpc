program fjf639f;

type
  t = object end;
  u = object (t) end;

var
  v: Integer;

begin
  with v as u do  { WRONG }
    WriteLn ('failed')
end.
