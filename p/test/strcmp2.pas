Program StrCmp2 ( Output );

{ FLAG --classic-pascal -Werror }

Var
  KO: packed array [ 1..2 ] of Char;

begin
  KO:= 'KO';
  if KO = 'OK' then
    writeln ( 'failed' )
  else
    writeln ( 'OK' );
end.
