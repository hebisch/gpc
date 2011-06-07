program fjf840d;

type
  v = record f: Integer end;

function h = r: v;
begin
  r.f := 42
end;

begin
  h.f := 17  { WRONG }
end.
