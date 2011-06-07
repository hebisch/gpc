unit fjf919u;

interface

type
  t = String (10);

operator pow (a, b: String) = c: t;

implementation

operator pow (a, b: String) = c: t;
begin
  c := a + b
end;

end.
