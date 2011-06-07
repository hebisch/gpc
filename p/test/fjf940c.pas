program fjf940c;

var
  a: array [1 .. 2] of packed array [1 .. 2, 1 .. 2] of Integer;

procedure p (var i: Integer);
begin
end;

begin
  p (a[1, 2, 1])  { WRONG }
end.
