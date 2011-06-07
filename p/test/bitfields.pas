Program BitFields;

Var
  Foo: packed record
    b: 0..63;
    a: 0..1;
  end { Foo };

  r: packed array [ 40..47 ] of 0..1;

  F: Text;

begin
  rewrite ( F );
  writeln ( F, '42' );
  writeln ( F, '0' );
  writeln ( F, '1' );
  with Foo do
    begin
      reset ( F );
      readln ( F, b );
      readln ( F, a );
      readln ( F, r [ 42 ] );
      close ( F );
      if ( b = 42 ) and ( a = 0 ) and ( r [ 42 ] = 1 ) then
        writeln ( 'OK' )
      else
        writeln ( 'failed: ', b, ' ', a, ' ', r [ 42 ] );
    end { with };
end.
