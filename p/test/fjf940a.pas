program fjf940a;

var
  a: packed array [1 .. 2] of Integer;

procedure p (var i: Integer);
begin
end;

begin
  p (a[1])  { WRONG }
end.
