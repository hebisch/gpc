program fjf639g;

type
  t = object end;
  u = object (t) end;

var
  v: ^t;

begin
  WriteLn ('failed ', v^ is Integer)  { WRONG }
end.
