Program CStrIni1;

{$X+}

Var
  c: CString = 'OK';
  s: array [ 1..6 ] of Char = 'failed';

begin
  s := s;
  writeln ( c );
end.
