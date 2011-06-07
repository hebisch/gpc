program fjf836;

type
  t = String (10) = 'OK';

var
  x: String (10);

function f = r: t;
begin
  WriteLn (r);
  r := 'failed'
end;

begin
  x := f
end.
