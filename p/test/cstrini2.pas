Program CStrIni2;

{$X+}

Var
  s: array [ -1..1 ] of Char = 'OK'#0;
  c: CString = s;

begin
  writeln ( c );
end.
