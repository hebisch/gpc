program fjf550b;

var i, j: Integer;

procedure foo (const j: Integer);
begin
  MoveLeft (i, j, 1)  { WRONG }
end;

begin
  foo (j);
  WriteLn ('failed')
end.
