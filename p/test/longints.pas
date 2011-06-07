Program LongInts;

Var
  Answer: LongInt = 42;
  S: String ( 2 );

begin
  WriteStr ( S, Answer );
  if S = '42' then
    writeln ( 'OK' )
  else
    writeln ( 'failed' );
end.
