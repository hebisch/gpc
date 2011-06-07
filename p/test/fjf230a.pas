program fjf230a;

type t = string (2);

operator and_then (a, b : char) = result : t;
begin
  result := a + b
end;

begin
  writeln ('O' and_then 'K')
end.
