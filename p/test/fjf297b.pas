program fjf297b;

procedure p (const s : String);
begin
  WriteLn (Copy (s, 5, 2))
end;

begin
  p (CString2String ('    OK'))
end.
