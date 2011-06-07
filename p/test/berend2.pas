Program Berend2 ( Output );

{ FLAG --extended-pascal -Werror }

begin
  case 42 of
    1: writeln ( 'failed' );
    2: writeln ( 'failed' );
  otherwise
    writeln ( 'OK' );
  end { case };
end.
