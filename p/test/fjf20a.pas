Program fjf20a;

Var
  a: Cardinal attribute ( Size = 8 );
  b: Integer attribute ( Size = 64 ) value 42;
  S: array [ 1..2 ] of Char;

begin
  a:= 31;
  if ( a = 31 ) and ( b = 42 ) then
    begin
      WriteStr ( S, a );
      if S = '31' then
        writeln ( 'OK' )
      else
        writeln ( 'failed' );
    end { if }
  else
    writeln ( 'failed' );
end.
