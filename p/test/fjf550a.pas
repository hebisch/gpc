program fjf550a;

var i, j: Integer;

procedure foo (const j: Integer);
begin
  Move (i, j, 1)  { WRONG }
end;

begin
  foo (j);
  WriteLn ('failed')
end.
