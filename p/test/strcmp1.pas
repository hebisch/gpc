Program StrCmp1 ( Output );

{ FLAG --classic-pascal -Werror }

begin
  if 'KO' = 'OK' then
    writeln ( 'failed' )
  else
    writeln ( 'OK' );
end.
