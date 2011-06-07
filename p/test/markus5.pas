Program Markus5;

{$w-}

Type
  FooBar = record
    c: Char;
  end { FooBar };

Operator bar ( x, y: FooBar ) = z: FooBar;

begin { FooBar bar FooBar }
  writeln ( x.c, y.c );
  z.c:= succ ( x.c, ord ( y.c ) );
end { FooBar bar FooBar };

Var
  foo: FooBar = ( c: 'O' );
  baz: FooBar = ( c: 'K' );

begin
  foo:= foo bar baz;
end.
