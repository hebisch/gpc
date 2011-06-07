Program fjf0;

Var
  i: Integer;
  w: Word value 7;

begin
  i:= w;
  if i = LongInt ( 7 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
