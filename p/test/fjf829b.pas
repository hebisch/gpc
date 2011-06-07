program fjf829b;

type
  t = object end;

var
  p: ^t;

procedure r;
begin
  WriteLn ('failed')
end;

begin
  Dispose (p, r)  { WRONG }
end.
