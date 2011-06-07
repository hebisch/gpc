program fjf565f;

function foo (bar: Integer): Integer;
var bar: Integer;  { WRONG }
begin
  Return 0
end;

begin
  WriteLn ('failed')
end.
