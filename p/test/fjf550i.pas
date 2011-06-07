program fjf550i;

var i, j: Integer;

procedure foo (protected j: Integer);
begin
  MoveRight (j, i, SizeOf (i))
end;

begin
  i := 42;
  j := 17;
  foo (j);
  if i = 17 then WriteLn ('OK') else WriteLn ('failed')
end.
