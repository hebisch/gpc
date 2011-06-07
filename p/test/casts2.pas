{ FLAG -fno-strict-aliasing }
Program Test;

Type
  RealInteger = Integer attribute ( size = bitsizeof ( ShortReal ) );

Var
  i: RealInteger;
  x: ShortReal absolute i;
  y: ShortReal;

begin
  y:= 3.14;
  i:= RealInteger ( y );
  if x = y then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
