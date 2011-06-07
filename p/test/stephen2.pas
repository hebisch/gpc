Program Stephen2;

{ FLAG --pedantic-errors }

Var
  b: Boolean;

begin
  b:= Boolean ( 3 );  { WRONG }
  writeln ( Integer ( b ) );
  writeln ( 'failed' );
end.
