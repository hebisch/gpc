Program ReadCStr1;

{$X+}

Var
  O, K: Integer;
  OK: CString = '79 75';

begin
  ReadStr ( OK, O, K );
  writeln ( chr ( O ), chr ( K ) );
end.
