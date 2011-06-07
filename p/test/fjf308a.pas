program fjf308a;

type tstring = string (10);

operator + (a, b : string) = c : tstring;
begin
  c := a;
  insert (b, c, 1)
end;

begin
  writeln ('K' + 'O')
end.
