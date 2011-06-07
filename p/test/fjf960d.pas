program fjf960d;

type
  a = procedure;
  c = procedure (a: Integer);

var
  b: a = nil;
  d: c = nil;

begin
  if b = d then WriteLn ('failed')  { WRONG }
end.
