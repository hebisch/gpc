{$W no-parentheses}

Program Chris5;

{ This program checks the internal representation of sets. }
{ This representation may change without notice, so do not }
{ refer to it in your programs!                            }

Type
  TSetElement = MedCard;

Const
  SetWordSize = BitSizeOf ( TSetElement );

Var
  Foo: set of Byte;
  Bar: packed array [ 0 .. ( 256 div SetWordSize ) - 1 ] of TSetElement absolute Foo;
  Baz: set of Byte = [ 37, 42, 137, 200..220 ];
  i: Integer;

begin
  for i:= 0 to 255 do
    if i in [ 37, 42, 137, 200..220 ] then
      or ( Bar [ i div SetWordSize ],  1 shl ( i mod SetWordSize) );
  if Foo = [ 37, 42, 137, 200..220 ] then
    writeln ( 'OK' )
  else
    begin
      writeln ( 'failed' );
      write ( 'Foo:' );
      for i:= 0 to 255 do
        if i in Foo then
          write ( ' ', i );
      writeln;
      write ( 'Bar:' );
      for i:= 0 to 255 do
        if Bar [ i div 8 ] and ( 1 shl ( i mod 8 ) ) <> 0 then
          write ( ' ', i );
      writeln;
      write ( 'Baz:' );
      for i:= 0 to 255 do
        if i in Baz then
          write ( ' ', i );
      writeln;
    end { else };
end.
