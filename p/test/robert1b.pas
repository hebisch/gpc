program robert1b (input, output);

var
  y : real;

begin
  y := 5.57;
  if trunc (10.0 ** y) = 371535 then writeln ('OK') else writeln ('Failed')
end.
