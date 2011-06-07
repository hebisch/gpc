program fjf565e;

function foo (bar: Integer) = bar: Integer;  { WRONG }
begin
  Return 0
end;

begin
  WriteLn ('failed')
end.
