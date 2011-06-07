program fjf550h;

var i, j: Integer;

procedure foo (const j: Integer);
begin
  MoveLeft (j, i, SizeOf (i))
end;

begin
  i := 42;
  j := 17;
  foo (j);
  if i = 17 then WriteLn ('OK') else WriteLn ('failed')
end.
