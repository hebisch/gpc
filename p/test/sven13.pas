Program Sven13;

Type
  CharPtr = ^Char;
  FooPtr = ^FooRec;
  FooRec = record
    K: Char;
  end { FooRec };

Var
  MyChar: Char;
  MyFoo: FooRec;

Function O: CharPtr;

begin { O }
  O:= @MyChar;
end { O };

Function Foo: FooPtr;

begin { Foo }
  Foo:= @MyFoo;
end { Foo };

begin
  MyChar:= 'O';
  MyFoo.K:= 'K';
  writeln ( O^, Foo^.K );
end.
