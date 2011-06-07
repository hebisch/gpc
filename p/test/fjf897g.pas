program fjf897f;

procedure p (m: Integer);
var a: array [1 .. m] of Integer;
begin
  SizeOf(a) := 0  { WRONG }
end;

begin
end.
