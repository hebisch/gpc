program fjf861;

var
  a: Integer attribute (Size = 16);
  b: Word attribute (Size = 16);
  c: Cardinal attribute (Size = 16);
  d: Boolean attribute (Size = 16);

begin
  if (Low (a) = -$8000) and (High (a) = $7fff) and (BitSizeOf (a) = 16) and
     (Low (b) = 0) and (High (b) = $ffff) and (BitSizeOf (b) = 16) and
     (Low (c) = 0) and (High (c) = $ffff) and (BitSizeOf (c) = 16) and
     (Low (d) = False) and (High (d)) and (BitSizeOf (d) = 16) then
    WriteLn ('OK')
  else
    WriteLn ('failed ', Low (a), ' ', High (a), ' ', BitSizeOf (a), ' ',
                        Low (b), ' ', High (b), ' ', BitSizeOf (b), ' ',
                        Low (c), ' ', High (c), ' ', BitSizeOf (c), ' ',
                        Low (d), ' ', High (d), ' ', BitSizeOf (d))
end.
