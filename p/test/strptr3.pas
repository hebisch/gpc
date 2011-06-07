Program StrPtr3;

{$if 0}
{$W-}

Type
  SO = String ( ord ( 'O' ) - ord ( 'A' ) );

Var
  { Cf. the comment in strptr2.pas }
  OK: array [ 1..2 ] of ^SO = ( @'abcdefghijklmnopqrstuvwxyz', @'bcdefghijk' );
{$else}
Var
  OK: array [ 1..2 ] of ^String = ( @'abcdefghijklmn', @'bcdefghijk' );
{$endif}

begin
  write ( chr ( ord ( 'A' ) + OK [ 1 ]^.Capacity ) );
  write ( chr ( ord ( 'A' ) + length ( OK [ 2 ]^ ) ) );
  writeln;
end.
