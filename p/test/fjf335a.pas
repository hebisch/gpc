program fjf335a;

const
  o : set of char = ['O'] + ['K'];

var
  a : char;

begin
  for a := 'Z' downto 'A' do
    if a in o then write (a);
  writeln
end.
