program fjf374;

var
  a : boolean;
  i : integer;

begin
  i := 0;
  for a := true downto false do inc (i);
  if i = 2 then writeln('OK') else writeln ('failed')
end.
