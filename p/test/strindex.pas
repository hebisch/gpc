Program StrIndex;

Var
  S: array [ 1..2 ] of String ( 10 ) = ( 'xyz', 'abcdeOK' );

Procedure WriteString ( S: String );

begin { WriteString }
  write ( S );
end { WriteString };

begin
  WriteString ( S [ 2 ] [ 6 ] );
  writeln ( S [ 2 ] [ 7 ] );
end.
