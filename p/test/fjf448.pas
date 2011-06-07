program fjf448;

type
  RealType    = ShortReal;
  IntegerType = Integer attribute (Size = BitSizeOf (RealType));

var
  i : IntegerType;
  r : RealType;

begin
  r := 41.9;
  i := IntegerType (r + 0); { WRONG }
  WriteLn ('failed')
end.
