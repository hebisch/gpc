program fjf450f;

procedure foo (...); external name 'foo';
procedure bar (s : CString); attribute (name = 'foo'); forward;
procedure bar (s : CString);
begin
  WriteLn (CString2String (s))
end;

begin
  foo (CString ('xx'))  { WRONG Frank, 20030317 }
end.
