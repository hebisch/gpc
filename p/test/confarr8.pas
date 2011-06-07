Program ConfArr8;

Type
  Fix2 = packed array [ 42..43 ] of Char;

Procedure Foo ( OK: array [ a..b: Integer ] of packed array [ c..d: Integer ] of Char );

begin { Foo }
  writeln ( OK [ b ] );
end { Foo };

Var
  Bar: array [ 1..12 ] of Fix2;

begin
  FillChar ( Bar, SizeOf ( Bar ), 'x' );
  Bar [ 12 ]:= 'OK';
  Foo ( Bar );
end.
