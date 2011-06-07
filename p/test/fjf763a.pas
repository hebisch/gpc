program fjf763a;

type
  t (i: Integer) = array [0 .. 15] of Char;

var
  n: Integer = 16;
  v: ^t;

procedure p (const a, b: String);
begin
  if Length (b) = 16 then WriteLn ('OK') else WriteLn ('failed ', Length (b))
end;

begin
  New (v, n);
  p ('abc', v^[0 .. n - 1])
end.
