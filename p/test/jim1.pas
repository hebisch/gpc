Program Jim1 ( Output );

Import
  catch22 in 'jim1foo.pas';

begin
  setfoo ( 42 );
  if getfoo = 42 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
