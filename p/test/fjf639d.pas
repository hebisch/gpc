{$extended-pascal}

program fjf639d (Output);

type
  t = object end;
  u = object (t) end;

var
  v: ^t;

begin
  with v^ as u do  { WRONG }
    WriteLn ('failed')
end.
