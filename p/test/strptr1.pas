Program StrPtr1;

Var
  OK: array [ 1..2 ] of ^String = ( @'bcdefghijklmno', @'bcdefghijk' );

begin
  write ( chr ( ord ( 'A' ) + OK [ 1 ]^.Capacity ) );
  write ( chr ( ord ( 'A' ) + length ( OK [ 2 ]^ ) ) );
  writeln;
end.
