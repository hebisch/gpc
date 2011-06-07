program fjf940e;

var
  a: array [1 .. 2] of packed array [3 .. 4, 5 .. 6] of Integer;

procedure p (var x: array [a .. b: Integer] of array [c .. d: Integer] of packed array [e .. f: Integer] of Integer);
begin
end;

begin
  p (a)  { WRONG }
end.
