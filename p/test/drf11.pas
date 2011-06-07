program drf11;

type
  x = packed record
    x, y : ByteBool
  end;

var
  xx : x;

begin
  if (SizeOf (x) = 2) and (SizeOf (xx) = 2) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', SizeOf (x), ' ', SizeOf (xx))
end.
