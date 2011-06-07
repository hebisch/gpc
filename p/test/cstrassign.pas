Program CStrAssign;

{$X+}

Var
  OK : array [ 1..9 ] of Char;
  p : CString;
  s : String (10);

begin
  OK := '---failed';
  OK := 'OK';
  p := OK;
  writestr (s, p);
  writeln (trim (s))
end.
