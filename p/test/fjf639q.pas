program fjf639q;

type
  t = object end;
  u = object (t) end;

var
  v: t;

begin
  WriteLn ('failed ', v is u)  { WARN }
end.
