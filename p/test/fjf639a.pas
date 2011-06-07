{$borland-pascal}

program fjf639a;

type
  t = object end;
  u = object (t) end;

var
  v: ^t;

begin
  WriteLn ('failed ', v^ is u)  { WRONG }
end.
