program Peter2d;

procedure p (a: array [m .. n: Integer] of Integer);
begin
end;

var
   a: array [4 .. 10] of Integer;
begin
   p (a[5..4])  { WRONG }
end.
