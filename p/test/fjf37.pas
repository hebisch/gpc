Program fjf37;

Function Check ( C: Char ): Char;

Var
  X: Integer attribute (Size = 13 );
  S: String ( 13 );

begin { Check }
  X:= ord ( C );
  WriteStr ( S, X );
  ReadStr ( S, X );
  Check:= chr ( X );
end { Check };

begin
  writeln ( Check ( 'O' ), Check ( 'K' ) );
end.
