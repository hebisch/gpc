program fjf230b;

type t = string (2);

operator followed_by (a, b : char) = result : t;
begin
  result := a + b
end;

begin
  writeln ('O' followed_by 'K')
end.
