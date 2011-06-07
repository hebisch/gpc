program fjf897f;

procedure p (m: Integer);
var a: array [1 .. m] of Integer;
begin
  High (a) := 0  { WRONG }
end;

begin
end.
