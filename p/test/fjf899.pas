{$borland-pascal}

program fjf899;

type
  a = packed 1 .. 10;

begin
  if (Low (a) = 1) and (High (a) = 10) then WriteLn ('OK') else WriteLn ('failed')
end.
