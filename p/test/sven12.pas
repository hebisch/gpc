{ BUG: Fails with 2.8.1 with -O3 without --force-addr.
  Seems to be ok with 2.95.x. }

Program Sven12;

Type
  Foo = record
    a: Integer;
    b: Real;
  end { Foo };

Var
  F: Foo;

Operator * ( x: Real; y: Foo ) = z: Foo;

begin { Real * Foo }
  z.a:= Round ( x ) + y.a;
  z.b:= x * y.b;
end { Real * Foo };

Function Nop ( Const F: Foo ): Foo;

begin { Nop }
  Nop:= F;
end { Nop };

begin
  F.a:= 116;
  F.b:= 2;
  F:= Nop ( 21.0 * F );
  if ( F.a = 137 ) and ( F.b = 42 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', F.a, ' ', F.b : 0 : 2 );
end.
