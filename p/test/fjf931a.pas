{$W dynamic-arrays}

program fjf931a;

procedure p (i: Integer);
var
  a: array [1 .. i] of Integer;  { WARN }
begin
  a[1] := 42
end;

begin
  p (4)
end.
