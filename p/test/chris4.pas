{$W no-parentheses}

Program Chris4;

{ This program checks the internal representation of sets. }
{ This representation may change without notice, so do not }
{ refer to it in your programs!                            }

Type
  TSetElement = MedCard;

Const
  SetWordSize = BitSizeOf ( TSetElement );

Var
  Foo: set of Byte = [ 37, 42, 137, 200..220 ];
  Bar: packed array [ 0 .. ( 256 div SetWordSize ) - 1 ] of TSetElement absolute Foo;
  i: Integer;
  okay: Boolean = true;

begin
  for i:= 0 to 255 do
    if ( Bar [ i div SetWordSize ] and ( 1 shl ( i mod SetWordSize ) ) <> 0 )
       <> ( i in [ 37, 42, 137, 200..220 ] ) then
      okay:= false;
  if okay then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
