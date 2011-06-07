program fjf621;

const
  a = ['O'];
  b = a + ['K'];

var
  c: Char;

begin
  for c := 'Z' downto 'A' do
    if c in b then Write (c);
  WriteLn
end.
