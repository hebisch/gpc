Program fjf38d ( Output );

{ FLAG --borland-pascal --no-exact-compare-strings }

Var
  foo: Boolean;

begin
  foo := foo;
  if ( '' = ' ' ) and ( '' = '     ' ) then   { Equal according to ISO, but ... :-( }
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
