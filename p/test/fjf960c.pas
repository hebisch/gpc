program fjf960c;

type
  a = procedure;

var
  b: a = nil;

begin
  if nil = b then WriteLn ('OK') else WriteLn ('failed')
end.
