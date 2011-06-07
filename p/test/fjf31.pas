Program fjf31;

Type
  packedSubrange = packed 1..6;

Var
  foo: record
    a, b: packed 1..6;
  end { foo };

  bar: packed record
    a, b: 1..6;
  end { bar };

  foobar: packed record
    a, b: packed 1..6;
  end { bar };

begin
  if ( SizeOf ( foo ) in [2 * SizeOf ( packedSubrange ) .. SizeOf (Pointer)] )
     and ( SizeOf ( bar ) = 1 )
     and ( SizeOf ( foobar ) = 1 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', SizeOf ( foo ), ', ',
              SizeOf ( bar ), ', ', SizeOf ( foobar ) );
end.
