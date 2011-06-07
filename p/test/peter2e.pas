program Peter2e;

procedure p (a: array [m .. n: Integer] of Integer);
begin
end;

var
   a: array [4 .. 10] of Integer;
begin
   p (a[3 .. 6])  { WRONG }
end.
