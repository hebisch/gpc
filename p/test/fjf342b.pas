program fjf342b;

type
  T = 1 .. MaxInt;
  TIntegers (Size : T) = array [1 .. Size] of Integer;

var
  a : TIntegers (42);

begin
  if a.Size = 42 then WriteLn ('OK') else WriteLn ('failed')
end.
