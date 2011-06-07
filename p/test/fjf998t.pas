program fjf998t (Output);

const
  a = 2 pow (BitSizeOf (LongestInt) - 2);

begin
  if a = 1 shl (BitSizeOf (LongestInt) - 2) then WriteLn ('OK') else WriteLn ('failed ', a)
end.
