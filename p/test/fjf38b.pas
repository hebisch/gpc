Program fjf38b;

{ no flag, the default should be exact comparisons }

Var
  foo: Boolean;

begin
  foo:= {$local W-} '' = ' ' {$endlocal};  { Equal according to ISO, but ... }
  if foo then
    writeln ( 'failed' )
  else
    writeln ( 'OK' );
end.
