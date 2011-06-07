program Foo (Input, Output);

procedure Bar (S: CString);
begin
  {$local X+}
  WriteLn (S);
  {$endlocal}
end;

var
  S: String (20);

begin
  S := 'failedOKfailed';
  Bar (S[7 .. 8])
end.
