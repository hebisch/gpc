Program Assgnd1;

{$X+,W-}

Var
  Foo1, Foo2: Procedure ( OK: CString );
  Bar1: CString value Nil;
  Bar2: CString value 'OK';

Procedure FooBar ( OK: CString );

begin { FooBar }
  writeln ( OK )
end { FooBar };

begin
  @Foo1:= Nil;
  Foo2:= FooBar;
  if not assigned ( Foo1 )
     and assigned ( Foo2 )
     and not assigned ( Bar1 )
     and assigned ( Bar2 ) then
    Foo2 ( Bar2 );
end.
