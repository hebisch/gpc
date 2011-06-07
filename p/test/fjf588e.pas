program fjf588e;

type
  t (d: Integer) = array [False .. (d > 10)] of Integer;

var
  a: t (10);
  b: t (20);

begin
  if SizeOf (a) <> 2 * SizeOf (Integer) then begin WriteLn ('failed 1 ', SizeOf (a)); Halt end;
  if SizeOf (b) <> 3 * SizeOf (Integer) then begin WriteLn ('failed 2 ', SizeOf (b)); Halt end;
  WriteLn ('OK')
end.
