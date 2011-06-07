Program ChrCmp ( Output );

{ FLAG -Werror --classic-pascal }

begin
  if 'K' < 'O' then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
