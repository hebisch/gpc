Program Pack2;

Var
  a: packed array [ 1..188 ] of Boolean;
  {$W-}
  ai: Integer absolute a;
  i: Integer;
  {$W+}

begin
  ai:= 0;
  a [ 1 ]:= true;
  a [ 2 ]:= true;
  a [ 3 ]:= true;
  for i:= 1 to 188 do
    if not a [ i ] then
      a [ i ]:= true;
  if ( SizeOf ( a ) = 24 ) and ( ai = -1 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', SizeOf ( a ), ' ', ai );
end.
