Unit BO5_11u;

Interface

Procedure FooWriteString ( Var x; Const S: String );

Var
  Foo: record
    Size, NegSize: Integer;
    WriteString: ^Procedure ( Var x; Const S: String );
  end { Foo }
  value ( 4, -4, @FooWriteString );

Implementation

Procedure FooWriteString ( Var x; Const S: String );

begin { FooWriteString }
  writeln ( S );
end { FooWriteString };

end.
