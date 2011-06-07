Program Alpha2;

Var
  OK: array [ 1..2 ] of Integer;
  i: Integer;

begin
  for i:= 1 to 2 do
    if i = 1 then
      OK [ i ]:= ord ( 'O' )
    else
      OK [ i ]:= ord ( 'K' );
  writeln ( chr ( OK [ 1 ] ), chr ( OK [ 2 ] ) );
end.
