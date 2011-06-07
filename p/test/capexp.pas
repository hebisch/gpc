Program CapExp;

{ FLAG --no-write-real-blank --write-capital-exponent }

Var
  S: String ( 6 );

begin
  WriteStr ( S, 3.14159265358979323846 : 6 );
  if S = '3.1E+0' then
    begin
      {$no-write-capital-exponent}
      WriteStr ( S, 3.14159265358979323846 : 6 );
      if S = '3.1e+0' then
        writeln ( 'OK' )
      else
        writeln ( 'failed (2): ', S );
    end { if }
  else
    writeln ( 'failed (1): ', S );
end.
