{ BUG: types that depend on a variable's value }

program Couper5;

var
  XValueMax :Byte = 125;

Type
  T_XValue = Packed 0..XValueMax;

begin
  XValueMax := 0;
  if High (T_XValue) = 125 then
    WriteLn ('OK')
  else
    WriteLn ('failed ', High (T_XValue))
end.
