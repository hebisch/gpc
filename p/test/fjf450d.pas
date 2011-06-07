program fjf450d;

procedure foo (s : CString);
begin
  WriteLn (CString2String (s))
end;

var
  s : String (10) = 'O';

begin
  foo (s + 'K')
end.
