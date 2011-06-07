Program ReDef;

Type
  LongInt = Char;

Var
  Exit: LongInt value 'O';
  Assign: String ( 3 ) value 'JKL';

begin
  writeln ( Exit, Assign [ 2 ] );
end.
