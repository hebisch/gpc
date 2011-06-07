Program HighLow4;

Var
  Cmulb: array [ 'K'..'O' ] of Byte;

Procedure Bar ( foo: array of Byte );

begin { Bar }
  if ( low ( foo ) = 0 ) and ( high ( foo ) = ord ( 'O' ) - ord ( 'K' ) ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end { Bar };

begin
  Bar ( Cmulb );
end.
