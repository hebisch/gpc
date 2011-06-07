program fjf768b;

type
  r = record b: array [1 .. 10] of 0 .. 1 end;

procedure p (const a: r);
var i: Integer;
begin
  with a do
    for i in [b[1], 0] do  { No warning here }
end;

begin
  WriteLn ('OK')
end.
