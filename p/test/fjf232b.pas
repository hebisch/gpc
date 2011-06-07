program fjf232b;

type
  t = record
    a:Integer
  end;

var
  X, Y: t;
  z: Integer;

operator + (var a, b : t) = c : Integer;
begin
  c:= a.a + b.a;
  b.a:= 0
end;

begin
  X.a:= 35;
  Y.a:= 7;
  z:= X + Y;
  if ( z = 42 ) and ( Y.a = 0 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
