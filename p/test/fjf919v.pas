unit fjf919v;

interface

type
  t = String (10);

operator pow (a, b: t): t;  { WRONG }

implementation

operator pow (a, b: t): t;
begin
  t := a + b
end;

end.
