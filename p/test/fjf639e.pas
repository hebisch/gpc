program fjf639e;

type
  t = object end;
  u = object (t) end;

var
  v: Integer;

begin
  WriteLn ('failed ', v is u)  { WRONG }
end.
