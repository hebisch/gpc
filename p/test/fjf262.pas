program fjf262;

var
  s : set of char;
  t : char;

begin
  s := ['K'];
  t := 'O';
  s := s + [t];
  for t := 'Z' downto 'A' do
    if t in s then write (t);
  writeln
end.
