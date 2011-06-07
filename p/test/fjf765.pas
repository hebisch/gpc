program fjf765;

var
  X: Integer;
  Y, Z: LongInt;

begin
  X := -8;
  Y := High (Y);
  Z := X mod Y;
  if Z = High (Z) - 8 then WriteLn ('OK') else WriteLn ('failed ', Z, ' ', High (Z) - 8)
end.
