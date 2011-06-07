Program Tom1;

uses
  charbug1 in 'tom1m.pas';

begin
  if IsAlphaNum ( 'O' ) and IsAlphaNum ( 'k' ) and not IsAlphaNum ( '@' ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
