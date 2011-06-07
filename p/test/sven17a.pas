Program Sven17a;

Type
  Foo = array [ 1..2 ] of Char;

Operator * ( x: Real; F: Foo ) = OK: Foo;

begin { Real * Foo }
  OK:= 'OK';
end { Real * Foo };

Var
  KO: Foo = 'xy';

begin
  writeln ( 42.0 * KO );
end.
