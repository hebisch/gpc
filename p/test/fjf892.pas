program fjf892;

type
  a = object end;
  b = restricted a;
  c = object (b) end;  { WRONG }

begin
end.
