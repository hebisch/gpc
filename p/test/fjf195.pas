program fjf195;
uses fjf195u;
var c:char;
begin
  for c:='Z' downto 'A' do
    if c in ko then write(c);
  writeln;
end.
