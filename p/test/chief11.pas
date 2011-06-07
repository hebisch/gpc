Program Chief11;

Var
  KO: array [ 1..2 ] of Char value 'OK';


Procedure Foo ( Var x );

Var
  OK: array [ 1..2 ] of Char absolute x;

begin { Foo }
  writeln ( OK );
end { Foo };


Procedure Bar ( Var y );

begin { Bar }
  Foo ( y );
end { Bar };


begin
  Bar ( KO );
end.
