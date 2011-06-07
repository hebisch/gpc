{ BUG: types that depend on a variable's value }

program Couper3;

var
  XValueMax :Byte = 125;

Type
  T_XValue = Packed 0..XValueMax;

begin
  if SizeOf (T_XValue) = SizeOf (Byte) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', SizeOf (T_XValue))
end.
