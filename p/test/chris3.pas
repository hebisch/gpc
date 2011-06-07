Program Chris3;

Var
  x: record
    case Boolean of
      true: ( rec: record
                name: String ( 3 );
              end { rec } );
      false: ( Foo: Integer );
  end { x };

begin
  if x.rec.name.capacity = 3 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
