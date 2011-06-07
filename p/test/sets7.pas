Program Sets7;

{$W-}

Function Foo: Integer;

begin { Foo }
  Foo:= 42;
end { Foo };

begin
  if [ ] <= [ Foo ] then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
