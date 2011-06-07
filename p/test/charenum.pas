Program CharEnum;

Var
  x: 'K'..'O';

begin
  if SizeOf ( x ) = 1 then
    begin
      {$W-} x:= 'Onkel'; {$W+}
      write ( x );
      x:= 'K';
      writeln ( x );
    end { if }
  else
    writeln ( 'failed' );
end.
