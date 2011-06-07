program fjf749a;

type
  s1 = set of Char;
  s2 = set of 'A' .. 'Z';

procedure foo (a: s2);
var c: Char;
begin
  for c := 'Z' downto 'A' do
    if c in a then Write (c);
  WriteLn
end;

begin
  foo (['K', 'O'])
end.
