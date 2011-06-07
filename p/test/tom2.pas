Program Tom2;

uses
  charbug2 in 'tom2m.pas';

begin
  if IsAlphaNum ( 'O', 42 )
     and IsAlphaNum ( 'k', 137 )
     and not IsAlphaNum ( '@', 7 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
