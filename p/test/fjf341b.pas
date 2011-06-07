program fjf341b;

type
  Natural = 1 .. MaxInt;
  TIntegers (Size : Natural) = array [1 .. 2 * Size] of Integer;

var
  a : TIntegers (42);

begin
  if High (a) = 84 then WriteLn ('OK') else WriteLn ('failed')
end.
