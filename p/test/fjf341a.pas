program fjf341a;

type
  Natural = 1 .. MaxInt;
  TIntegers (Size : Natural) = array [1 .. Size] of Integer;

var
  a : TIntegers (42);

begin
  if a.Size = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
