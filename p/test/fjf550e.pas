program fjf550e;

var i, j: Integer;

procedure foo (protected j: Integer);
begin
  MoveLeft (i, j, 1)  { WRONG }
end;

begin
  foo (j);
  WriteLn ('failed')
end.
