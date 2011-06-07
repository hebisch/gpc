program fjf837e;

var
  i: Integer;

procedure p;
begin
  Inc (i)
end;

begin
  for i := 1 to 2 do  { WARN, because i is modified in p }
end.
