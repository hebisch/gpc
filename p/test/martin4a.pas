{ Simplified version of martin4b.pas }

program martin4a;

type
  t = packed 0..31;

function f (p : t): integer;
begin
  if (p < 21) or (p > 25) then
    f := 100
  else
    f := 200
end;

var
  v: integer;

begin
  for v := 0 to 31 do
    if f (v) <> 100 + 100 * Ord (v in [21 .. 25]) then
      begin
        WriteLn ('failed ', v);
        Halt
      end;
  WriteLn ('OK')
end.
