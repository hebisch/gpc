Program Alpha1;

Function Nop ( X: Char ): Char;

begin { Nop }
  return X;
end { Nop };

begin
  writeln ( Nop ( 'O' ), Nop ( 'K' ) );
end.
