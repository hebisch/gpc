program fjf726h;

begin
  if (High (Integer) = MaxInt) and (Low (Integer) <= -MaxInt) then WriteLn ('OK') else WriteLn ('failed')
end.
