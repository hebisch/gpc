Program fjf19;

uses
  fjf19u;

begin
  if SizeOf ( Card8 ) = 1 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
