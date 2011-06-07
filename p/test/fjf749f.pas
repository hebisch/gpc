program fjf749f;

type
  t = set of 'A' .. 'Z';

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
