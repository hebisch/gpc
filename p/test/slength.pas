Program SLength;

{$X+}

Var
  S: String ( 8 ) = 'OKfailed';

begin
  SetLength ( S, 2 );
  writeln ( S );
end.
