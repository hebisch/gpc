Program BoolSub;

Var
  boo: false..true;

begin
  boo:= true;
  if boo then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
