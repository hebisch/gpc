Program VarRec2;

Type
  FooRec = record
    case x: Integer of
      1: ( y1, y2: Integer );
      2: ( z: Integer );
  end { FooRec };

  FooPtr = ^FooRec;

Var
  Foo: FooRec;
  Bar: FooPtr;
  n: Integer value 0;

Procedure Check ( a, b: Integer );

begin { Check }
  Inc (n);
  if a <> b then
    begin
      writeln ( 'failed ', n, ' ', a, ' ', b );
      Halt ( 1 )
    end { if }
end { Check };

begin
  Check ( SizeOf ( FooRec ), 3 * SizeOf ( Integer ) );
  Foo.x:= 1;
  Check ( SizeOf ( Foo ), 3 * SizeOf ( Integer ) );
  Foo.x:= 2;
  Check ( SizeOf ( Foo ), 3 * SizeOf ( Integer ) );
  Bar:= New ( FooPtr, 1 );
  Check ( Bar^.x, 1);
  Check ( SizeOf ( Bar^ ), 3 * SizeOf ( Integer ) );
  Bar:= New ( FooPtr, 2 );
  Check ( Bar^.x, 2);
  { This is not guaranteed by the standards, and GPC does not behave like this.
    -- Frank
  Check ( SizeOf ( Bar^ ), 2 * SizeOf ( Integer ) ); }
  writeln ( 'OK' )
end.
