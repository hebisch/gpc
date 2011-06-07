{ Failed on mips-sgi-irix. }

Program Pack5;

Var
  x: packed array [ 1..3 ] of Boolean;
  i: Integer;

begin
  i:= 2;
  x [ 1 ]:= true;
  x [ 2 ]:= false;
  x [ 3 ]:= true;
  for i:= 1 to 3 do
    x [ i ]:= not x [ i ];
  if not x [ 1 ] and x [ 2 ] and not x [ 3 ] then
    writeln ( 'OK' )
  else
    writeln ( 'failed ', x [ 1 ], ' ', x [ 2 ], ' ', x [ 3 ] );
end.
