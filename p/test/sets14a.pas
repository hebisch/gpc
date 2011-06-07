program Sets14a;

var
  foo: set of 'C'..'X' value ['K', 'M'];
  i: Char;

begin
  i := 'M';
  Exclude (foo, i);
  i := 'O';
  Include (foo, i);
  for i:= 'X' downto 'C' do
    if i in foo then
      write (i);
  writeln
end.
