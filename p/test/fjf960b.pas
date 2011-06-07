program fjf960b;

type
  a = procedure;

var
  b: a = nil;

const
  c = a (0);

begin
  if b = c then WriteLn ('OK') else WriteLn ('failed')
end.
