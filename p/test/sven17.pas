Program Sven17;

Type
  Foo = array [ 1..2 ] of Char;

Operator * ( x: LongReal; F: Foo ) = OK: Foo;

begin { LongReal * Foo }
  OK:= 'OK';
end { LongReal * Foo };

Var
  KO: Foo = 'xy';

begin
  writeln ( 42.0 * KO );
end.
