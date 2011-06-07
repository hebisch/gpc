program fjf450a;

procedure foo (s : CString);
begin
  WriteLn (CString2String (s))
end;

begin
  foo (CString ('xx'))  { WRONG Frank, 20030317 }
end.
