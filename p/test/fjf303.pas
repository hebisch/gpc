program fjf303;

var a : complex;
begin
  a := polar (1, 3 * pi / 2);
  if (abs (re (a)) < 1e-8) and (abs (im (a) + 1) < 1e-8) then writeln ('OK') else writeln ('Failed')
end.
