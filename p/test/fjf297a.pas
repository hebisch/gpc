program fjf297a;

procedure p (s : String);
begin
  WriteLn (Copy (s, 5, 2))
end;

begin
  p (CString2String ('    OK'))
end.
