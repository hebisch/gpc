program fjf550f;

var i, j: Integer;

procedure foo (protected j: Integer);
begin
  MoveRight (i, j, 1)  { WRONG }
end;

begin
  foo (j);
  WriteLn ('failed')
end.
