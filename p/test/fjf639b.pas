{$extended-pascal}

program fjf639b (Output);

type
  t = object end;
  u = object (t) end;

var
  v: ^t;

begin
  WriteLn ('failed ', v^ is u)  { WRONG }
end.
