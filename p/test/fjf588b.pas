program fjf588b;

type
  t (d: Integer) = array [0 .. 2 * d] of Integer;

var
  a: t (10);
  b: t (20);

begin
  if SizeOf (a) <> 22 * SizeOf (Integer) then begin WriteLn ('failed 1 ', SizeOf (a)); Halt end;
  if SizeOf (b) <> 42 * SizeOf (Integer) then begin WriteLn ('failed 2 ', SizeOf (b)); Halt end;
  WriteLn ('OK')
end.
