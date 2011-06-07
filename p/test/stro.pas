program stro(output);
var s : string(60);
begin
  s := StringOf('x15', 122, StringOf('bar', 7, 'x', 1.5, true),'v', 1.125);
  if s = 'x15122bar7x 1.500000000000000e+00Truev 1.125000000000000e+00' then
    writeln(StringOf('O', StringOf('K'))) 
end
.
