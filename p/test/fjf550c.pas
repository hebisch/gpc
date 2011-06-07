program fjf550c;

var i, j: Integer;

procedure foo (const j: Integer);
begin
  MoveRight (i, j, 1)  { WRONG }
end;

begin
  foo (j);
  WriteLn ('failed')
end.
