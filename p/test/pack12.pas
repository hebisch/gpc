Program Pack12;

Var
  Space1: LongestCard value 0;
  A: packed array [ 0..13 ] of 0..120;
  Space2: LongestCard value 0;
  B: packed array [ 0..SizeOf ( A ) - 1 ] of Byte absolute A;
  i: Integer;

begin
  Space1 := Space2;
  B := B;
  {$ifdef DEBUG }
    A [ 0 ]:= 65;
    A [ 1 ]:= 67;
    A [ 2 ]:= 69;
    A [ 3 ]:= 71;
    A [ 4 ]:= 73;
    A [ 5 ]:= 75;
    A [ 6 ]:= 77;
    A [ 7 ]:= 79;
    A [ 8 ]:= 81;
    A [ 9 ]:= 83;
    A [ 10 ]:= 85;
    A [ 11 ]:= 87;
    A [ 12 ]:= 89;
    A [ 13 ]:= 91;
    for i:= 0 to 13 do
      write ( A [ i ], ' ' );
    writeln;
    writeln ( A [ 0 ], ' ', A [ 1 ], ' ', A [ 2 ], ' ', A [ 3 ], ' ',
              A [ 4 ], ' ', A [ 5 ], ' ', A [ 6 ], ' ', A [ 7 ], ' ',
              A [ 8 ], ' ', A [ 9 ], ' ', A [ 10 ], ' ', A [ 11 ], ' ',
              A [ 12 ], ' ', A [ 13 ], ' ' );
    for i:= 0 to SizeOf ( A ) - 1 do
      write ( B [ i ], ' ' );
    writeln;
    for i:= 0 to SizeOf ( A ) - 1 do
      B [ i ]:= 0;
    for i:= 0 to 13 do
      begin
        A [ i ]:= 65 + 2 * i;
        write ( A [ i ], ' ' );
      end { for };
    writeln;
    for i:= 0 to 13 do
      write ( A [ i ], ' ' );
    writeln;
    writeln ( A [ 0 ], ' ', A [ 1 ], ' ', A [ 2 ], ' ', A [ 3 ], ' ',
              A [ 4 ], ' ', A [ 5 ], ' ', A [ 6 ], ' ', A [ 7 ], ' ',
              A [ 8 ], ' ', A [ 9 ], ' ', A [ 10 ], ' ', A [ 11 ], ' ',
              A [ 12 ], ' ', A [ 13 ], ' ' );
    for i:= 0 to SizeOf ( A ) - 1 do
      write ( B [ i ], ' ' );
    writeln;
  {$else }
    for i:= 0 to 13 do
      A [ i ]:= 65 + 2 * i;
  {$endif }
  for i:= 0 to 13 do
    if A [ i ] <> 65 + 2 * i then
      begin
        writeln ( 'failed: ', i, ' ', A [ i ] );
        Halt ( 1 )
      end { if };
  writeln ( 'OK' )
end.
