program fjf1023a;

type
  t (n: Integer) = array [1 .. n] of Integer;

var
  v: ^t;

procedure p (var a: t);
var b: type of a;
begin
  FillChar (v^, SizeOf (v^), 0);
  if High (b) = 10 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  New (v, 10);
  p (v^)
end.
