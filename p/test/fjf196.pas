program fjf196;

procedure foo;
var
  b:0..26;
  s:set of 1..24;
begin
  s:=[15];
  b:=11;
  s:=s+[b];
  for b:=26 downto 1 do
    if b in s then write(chr(ord('A')+b-1));
  writeln
end;

begin
  foo
end.
