Program Abso2;

{$W no-absolute}

Const
  thousand = 1000;

Var
  NilVar: Integer absolute thousand - 1000;

begin
  if @NilVar = Nil then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
