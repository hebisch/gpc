program fjf588d;

type
  t (d: Integer) = array [0 .. Sqr (d)] of Integer;

var
  a: t (10);
  b: t (20);

begin
  if SizeOf (a) <> 102 * SizeOf (Integer) then begin WriteLn ('failed 1 ', SizeOf (a)); Halt end;
  if SizeOf (b) <> 402 * SizeOf (Integer) then begin WriteLn ('failed 2 ', SizeOf (b)); Halt end;
  WriteLn ('OK')
end.
