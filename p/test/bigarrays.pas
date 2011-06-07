Program BigArrays;

Const
  MB = 1024 * 1024;

Var
  Big: array [ 1..MB ] of Char;
  i: Integer;

begin
  for i:= 1 to MB do
    Big [ i ]:= chr ( i mod 256 );
  writeln ( 'OK' );
end.
