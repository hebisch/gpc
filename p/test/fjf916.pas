program fjf916;

type
  p = ^Text;

var
  c: Integer = 0;

function f = r: p;
begin
  Inc (c);
  New (r)
end;

begin
  Dispose (f);
  if c = 1 then WriteLn ('OK') else WriteLn ('failed ', c)
end.
