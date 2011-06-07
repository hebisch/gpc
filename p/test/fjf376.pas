program fjf376;

type
  t = cardinal attribute (Size = 8);

begin
  if (not t (0)) = 255 then writeln ('OK') else writeln ('failed')
end.
