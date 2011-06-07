Program Addr1;

Var
  Foo: Integer;
  Bar: Procedure;

Procedure FooBar;

begin { FooBar }
  writeln ( 'OK' )
end { FooBar };

begin
  Bar:= FooBar;
  if ( addr ( Foo ) = @Foo )
     and ( addr ( Bar ) = @Bar )
     and ( addr ( Bar ) = @FooBar ) then
    Bar
  else
    writeln ( 'failed' )
end.
