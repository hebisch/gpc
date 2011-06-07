Program Casts3;

{$X+}

Type
  EightChars = array [ 1..8 ] of Char;

Var
  O: CString = '...O...';
  p: CString;
  x: LongInt;
  K: EightChars value '....K...';

begin
  p:= CString ( PtrInt ( O ) + 3 );
  write ( p^ );
  x:= LongInt ( K );
  writeln ( EightChars ( x ) [ 5 ] );
end.
