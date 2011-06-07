program fjf550d;

var i, j: Integer;

procedure foo (protected j: Integer);
begin
  Move (i, j, 1)  { WRONG }
end;

begin
  foo (j);
  WriteLn ('failed')
end.
