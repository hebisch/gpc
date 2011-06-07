Program fjf38;

{ FLAG --borland-pascal -w }

Var
  foo: Boolean;

begin
  foo:= '' = ' ';  { Equal according to ISO, but ... }
  if foo then
    writeln ( 'failed' )
  else
    writeln ( 'OK' );
end.
