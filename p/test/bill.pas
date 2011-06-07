Program Bar;

uses
  bill_Foo in 'bill_u.pas';

begin
  if DecToBin ( '42' ) = '101010' then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
