program fjf907;

const
  c = -(10 pow 16 - 1);

var
  a: c .. 10 pow 16 - 1;

begin
  if (SizeOf (a) >= 8) and (c = -9999999999999999) and (Low (a) = c) and (High (a) = -c) then
    WriteLn ('OK')
  else
    WriteLn (SizeOf (a), ' ', c, ' ', Low (a), ' ', High (a))
end.
