Program fjf38a ( Output );

{ FLAG --extended-pascal }

Var
  foo: Boolean;

begin
  foo := foo;
  if ( '' = ' ' ) and ( '' = '     ' ) then   { Equal according to ISO, but ... :-( }
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
