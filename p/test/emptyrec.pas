{ COMPILE-CMD: emptyrec.cmp }

Program EmptyRec;

Var
  foo: record
  end { foo };

begin
  foo := foo;
  writeln ( 'OK' );
end.
