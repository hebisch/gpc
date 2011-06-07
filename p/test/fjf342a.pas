program fjf342a;

type
  TIntegers (Size : 1 .. MaxInt) = array [1 .. Size] of Integer;
    { WRONG, according to ISO 10206, 6.4.7, only type names are
      allowed for discriminant declarations. }

begin
  WriteLn ('failed')
end.
