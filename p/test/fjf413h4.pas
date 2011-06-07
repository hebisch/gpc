program fjf413h4;

type
  t = (^a = ^b) .. True;

var
  v : t = False;

begin
  Inc (v);
  if v then WriteLn ('OK') else WriteLn ('failed')
end.
