Program BO5_19;

Var
  foo: record
    bar: ^String;
  end { foo };

  baz: String ( 42 );

begin
  foo.bar:= @baz;
  if SizeOf ( foo.bar^ ) = SizeOf ( baz ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', SizeOf ( foo.bar^ ) );
end.
