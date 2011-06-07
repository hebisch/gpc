program fjf639k;

type
  t = object end;
  u = object end;

var
  v: ^t;

begin
  WriteLn ('failed ', v^ is u)  { WRONG }
end.
