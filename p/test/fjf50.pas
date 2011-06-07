program fjf50;

{ FLAG -Werror }

function x y:integer;
begin
  readstr('3',y)
end;

begin
  if x = 3 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
