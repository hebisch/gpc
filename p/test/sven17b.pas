Program Sven17b;

Type
  Foo = array [ 1..2 ] of Char;

Operator * ( x: Extended; F: Foo ) = OK: Foo;

begin { Extended * Foo }
  OK:= 'OK';
end { Extended * Foo };

Var
  KO: Foo = 'xy';

begin
  writeln ( 42.0 * KO );
end.
