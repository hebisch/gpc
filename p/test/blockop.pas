Program BlockOp;

Const
  OK: array [ 1..2 ] of Char = 'OK';

Var
  F, G: File;
  Foo: Integer;
  Ch: Char;

begin
  Assign ( F, 'blockop.dat' );
  rewrite ( F, 2 );
  BlockWrite ( F, OK, 1, Foo );
  close ( F );
  if Foo = 1 then
    begin
      Assign ( G, 'blockop.dat' );
      reset ( G, 1 );
      repeat
        BlockRead ( G, Ch, 1, Foo );
        if Foo = 0 then
          writeln
        else
          write ( Ch );
      until Foo = 0;
      close ( G );
    end { if }
  else
    writeln ( 'failed' );
end.
