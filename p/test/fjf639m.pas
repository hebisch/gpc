program fjf639m;

type
  t = object end;
  u = object end;

var
  v: ^t;

begin
  WriteLn ('failed ', v^ is t)  { WARN }
end.
