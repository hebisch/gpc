Program PiConst;

Var
  S: String ( 16 );

begin
  WriteStr ( S, pi : 0 : 14 );
  if S = "3.14159265358979" then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
