Program Schema1c;

Type
  MyArray ( first: Integer; second, third: Char )
    = array [ 1..first, 'A'..second ] of 'A'..third;

Var
  O: MyArray ( 1, 'O', 'X' );
  K: MyArray ( 2, 'K', 'N' );

begin
  O [ 1, 'O' ]:= 'O';
  K [ 2, 'K' ]:= 'K';
{  writeln ( SizeOf ( O ) : 5, SizeOf ( K ) : 5 ); }
  writeln ( O [ 1, 'O' ], K [ 2, 'K' ] );
end.
