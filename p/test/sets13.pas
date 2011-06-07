program Sets13;

var
  foo: set of 'C'..'X' value ['K', 'M'];
  i: Char;

begin
  Exclude (foo, 'M');
  Include (foo, 'O');
  for i:= 'X' downto 'C' do
    if i in foo then
      write (i);
  writeln
end.
