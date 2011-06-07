Program fjf38c (Output);

{ FLAG --extended-pascal --exact-compare-strings -w }

Var
  foo: Boolean;

begin
  foo:= '' = ' ';  { Equal according to ISO, but ... }
  if foo then
    writeln ( 'failed' )
  else
    writeln ( 'OK' );
end.
