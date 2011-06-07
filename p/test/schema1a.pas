Program Schema1a;

Type
  MyArray ( upper: Char ) = array [ 'A' .. upper ] of Byte;

Var
  O: MyArray ( 'O' );
  K: MyArray ( 'K' );

begin
  O [ 'O' ]:= ord ( 'O' );
  K [ 'K' ]:= ord ( 'K' );
  { Size of schema: 1 byte for discriminant plus the array }
  writeln ( chr ( SizeOf ( O ) - SizeOf ( Char ) + ord ( pred ( 'A' ) ) ),
            chr ( SizeOf ( K ) - SizeOf ( Char ) + ord ( pred ( 'A' ) ) ) );
end.
