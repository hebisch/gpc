program fjf232c;

type
  t = record
    a,b:Integer
  end;

Var
  X, Y: t;

operator + (const a, b : t) = c : Integer;
begin
  c:= a.a + b.a
end;

begin
  X.a:= 35;
  Y.a:= 7;
  if X + Y = 42 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
