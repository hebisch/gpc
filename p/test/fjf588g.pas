program fjf588g;

type
  t (d: Boolean) = array [False .. (d and True)] of Integer;
  u (d: Integer) = array [-2 .. Ord ((d > 10) and (d < 30))] of Integer;

var
  a: t (False);
  b: u (20);
  c: u (30);

begin
  if (SizeOf (a) < SizeOf (Boolean) + SizeOf (Integer)) or (SizeOf (a) > 2 * SizeOf (Integer)) then begin WriteLn ('failed 1 ', SizeOf (a)); Halt end;
  if SizeOf (b) <> 5 * SizeOf (Integer) then begin WriteLn ('failed 2 ', SizeOf (b)); Halt end;
  if SizeOf (c) <> 4 * SizeOf (Integer) then begin WriteLn ('failed 3 ', SizeOf (b)); Halt end;
  WriteLn ('OK')
end.
