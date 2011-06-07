Program Sven16;

Var
  foo: Integer;

begin
  foo:= ParamCount + 1;
  if foo = 2 then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
