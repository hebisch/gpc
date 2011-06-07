{ FLAG -Wunused }

program fjf779b;

type
  t (n: Integer) = Integer;

var
  a: t (10);  { WARN }

begin
end.
