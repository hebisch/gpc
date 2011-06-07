program fjf458e;

procedure p;
var a: Integer = 1; attribute (static);
begin
  Inc (a)
end;

procedure q;
var a: Integer = 1; attribute (static);
begin
  if a = 1 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  p;
  q
end.
