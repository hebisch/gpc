program fjf450b;

procedure foo (s : CString);
begin
  WriteLn (CString2String (s))
end;

var
  s : String (10) = 'OK';

begin
  foo (s)
end.
