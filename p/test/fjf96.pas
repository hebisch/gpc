program fjf96;
var a:array[Boolean] of String[2000];
begin
  if ( a [ false ].Capacity = 2000 )
     and ( a [ true ].Capacity = 2000 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
