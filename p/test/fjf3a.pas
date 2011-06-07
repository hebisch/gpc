PROGRAM fjf3a;

Procedure Check;

type
 charset=set of Char;

var
  m:charset value ['O','K'];
  c:Char;

begin { check }
  for c:=chr(255) downto chr(0) do
    if c in m then write(c);
  writeln;
end { check };

begin
  Check;
end.
