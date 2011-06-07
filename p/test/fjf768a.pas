program fjf768a;

type
  r = record b: 0 .. 1 end;

procedure p (const a: r);
var i: Integer;
begin
  with a do
    for i in [b, 0] do  { No warning here }
end;

begin
  WriteLn ('OK')
end.
