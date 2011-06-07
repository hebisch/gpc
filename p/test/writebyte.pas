Program WriteByte;

Var
  a: array [ 0..3 ] of Byte value ( ord ( 'O' ), ord ( 'K' ), 42, 137 );
  S: String ( 255 );

begin
  WriteStr ( S, a [ 0 ], a [ 1 ] );
  if S = '7975' then
    writeln ( Char ( a [ 0 ] ), Char ( a [ 1 ] ) )
  else
    writeln ( 'failed' );
end.
