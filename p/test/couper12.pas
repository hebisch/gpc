Program LRealBug;
Var
  B : LongReal;
  TextFile : Text;
Begin
  Rewrite(TextFile);
  WriteLn(TextFile,'103000e-03');
  Reset(TextFile);
  ReadLn(TextFile,B);
  If B <> 103
    Then WriteLn('Failed')
    Else WriteLn('OK');
End.
