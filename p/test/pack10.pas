Program Pack10;

Type
  Foo ( n: Integer ) = packed array [ 1..n ] of Boolean;

Var
  a: ^Foo;
  b: Foo ( 12 );
  i: Integer;

begin
  New ( a, 6 );
  if ( BitSizeOf ( b ) > BitSizeOf ( a^ ) + BitSizeOf ( Integer ) )
     or ( BitSizeOf ( a^ ) > 2 * BitSizeOf ( Integer ) ) then
    writeln ( 'failed' )
  else
    begin
      for i:= 1 to 6 do
        a^ [ i ]:= i mod 3 = 1;
      for i:= 1 to 6 do
        if a^ [ i ] <> ( i mod 3 = 1 ) then
          begin
            writeln ( 'failed' );
            Halt ( 1 );
          end { if };
      writeln ( 'OK' );
    end { else };
end.
