program fjf940b;

var
  a: packed array [1 .. 2, 1 .. 2] of array [1 .. 2] of Integer;

procedure p (var i: Integer);
begin
  if i = 42 then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  a[1, 2, 1] := 42;
  p (a[1, 2, 1])
end.
