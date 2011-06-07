Program Bar;

uses
  TrunkUti in 'bill2_u.pas';

begin
  if DecToBin ( '42' ) = '101010' then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
