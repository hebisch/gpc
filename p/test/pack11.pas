Program Pack11;

Type
  Bits = packed array [ 0..31 ] of Boolean;
  BitsPtr = ^Bits;

Function Foo = B: BitsPtr;

Var
  i: Integer;
  called: Boolean value false; attribute (static);

begin { Foo }
  New ( B );
  for i:= 0 to 31 do
    B^ [ i ]:= odd ( i );
  if called then
    begin
      writeln ( 'failed (called)' );
      Halt ( 1 );
    end { if }
  else
    called:= true
end { Foo };

begin
  if Foo^ [ 7 ] then
    writeln ( 'OK' )
  else
    writeln ( 'failed (Foo)' )
end.
