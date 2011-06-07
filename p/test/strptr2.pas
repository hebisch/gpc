Program StrPtr2;

Type
  SO = String ( ord ( 'O' ) - ord ( 'A' ) );

Var
{$if 0}
  { Why should this work? SO is a string of capacity 14. But the constants
    have different length -- and also capacity since they're self contained
    (why should their type depend on the context?). Automatic constant
    conversion doesn't apply since the address is taken before seeing the
    context.) Even if the length would match, we'd have two distinct
    `String (14)' types which are not the same type in Pascal.
    -- Frank, 20030227 }
  OK: array [ 1..2 ] of ^SO = ( @'xy', @'bcdefghijk' );
{$else}
  Foo: array [ 1..2 ] of ^SO;
  OK: array [ 1..2 ] of ^String = ( @'xy', @'bcdefghijk' );
{$endif}

begin
{$if 0}
  write ( chr ( ord ( 'A' ) + OK [ 1 ]^.Capacity ) );
{$else}
  new (Foo [ 1 ]);
  write ( chr ( ord ( 'A' ) + Foo [ 1 ]^.Capacity ) );
{$endif}
  write ( chr ( ord ( 'A' ) + length ( OK [ 2 ]^ ) ) );
  writeln;
end.
