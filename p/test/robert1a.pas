program robert1a (input, output);

var
  y : real;
  x : longreal;

begin
  y := 5.57;
  x := 10.0;
  if trunc (x ** y) = 371535 then writeln ('OK') else writeln ('Failed')
end.
