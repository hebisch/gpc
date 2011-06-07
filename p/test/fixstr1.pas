Program Test;

Var
  OK: array [ 0..1 ] of Char = 'OK';

Procedure Foo ( Const Bar: String );

begin { Foo }
  writeln ( Bar );
end { Foo };

begin
  Foo ( OK );
end.
