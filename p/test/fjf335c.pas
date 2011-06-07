program fjf335c;

const
  o  = ['K', 'O', 'X'] - ['X'];

var
  a : char;

begin
  for a := 'Z' downto 'A' do
    if a in o then write (a);
  writeln
end.
