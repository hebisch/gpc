program fjf749d;

type
  t = set of Char;

procedure p (a: t);
var c: Char;
begin
  for c := 'Z' downto 'A' do
    if c in a then Write (c);
  WriteLn
end;

begin
  p (['O'] + ['K'])
end.
