Program goto1;

Label
  42;

Var
  x: Char;

begin
  x:= 'O';
  42: write ( x );
  if x = 'K' then
    writeln
  else
    begin
      x:= 'K';
      goto 42;
      writeln ( 'failed' );
      goto 42;
    end { else };
end.
