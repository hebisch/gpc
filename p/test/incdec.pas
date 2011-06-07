Program IncDec;

Var
  x, y: Integer;

begin
  x:= 0;
  while x <= $FF do
    begin
      if x = ord ( 'O' ) then
        begin
          write ( chr ( x ) );
          y:= x;
          while y > ord ( 'K' ) do
            dec ( y );
          writeln ( chr ( y ) );
        end { if };
      inc ( x );
    end { while };
end.
