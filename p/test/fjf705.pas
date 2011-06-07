program fjf705;

var
  n: Integer = 1;

procedure p;
var
  t: array [1 .. 1, 1 .. n] of Integer;

  procedure q;
  begin
    if t[1, 1] = 0 then WriteLn ('OK') else WriteLn ('failed')
  end;

begin
  t[1, 1] := 0;
  q
end;

begin
  p
end.
