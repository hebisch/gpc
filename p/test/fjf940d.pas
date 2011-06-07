program fjf940d;

var
  a: array [1 .. 2, 3 .. 4] of packed array [5 .. 6] of Integer;

procedure p (var x: array [a .. b: Integer] of array [c .. d: Integer] of packed array [e .. f: Integer] of Integer);
begin
  if (a = 1) and (b = 2) and (c = 3) and (d = 4) and (e = 5) and (f = 6) and (x[b, c, f] = 42) then
    WriteLn ('OK')
  else
    WriteLn ('failed')
end;

begin
  a [2, 3, 6] := 42;
  p (a)
end.
