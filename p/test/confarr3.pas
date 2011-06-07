Program ConfArr3;

Var
  OK: array [ 'D'..'O', 'K'..'Q' ] of Byte;

Procedure Foo ( a: array [ b..c: Char ] of array [ d..e: Char ] of Byte );

begin { Foo }
  writeln ( c, d );
end { Foo };

begin
  Foo ( OK );
end.
