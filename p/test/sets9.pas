Program Sets9;

{$W-}

Function Answer: Integer;

begin { Answer }
  Answer:= 42;
end { Answer };

begin
  if [ 42..137 ] = [ Answer..137 ] then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
