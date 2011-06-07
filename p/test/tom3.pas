Program Tom3;

uses
  charbug3 in 'tom3m.pas';

begin
  if IsAlphaNum ( 'O', 42 )
     and IsAlphaNum ( 'k', 137 )
     and not IsAlphaNum ( '@', 7 ) then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
