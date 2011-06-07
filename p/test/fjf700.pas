program fjf700;

type
  t = array [1 .. 8] of Boolean;
  u = array [1 .. 8] of Boolean;
  v = packed array [1 .. 2] of t;

begin
  if SizeOf (t) <> SizeOf (u) then
    WriteLn ('failed 1: ', SizeOf (t), ' ', SizeOf (u))
  else if SizeOf (v) <> 2 * SizeOf (t) then
    WriteLn ('failed 2: ', SizeOf (v))
  else
    WriteLn ('OK')
end.
