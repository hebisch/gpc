program fjf450e;

procedure foo (s : CString);
begin
  WriteLn (CString2String (s))
end;

var
  s : String (10) = 'x';

begin
  foo (CString (s + 'y'))  { WRONG Frank, 20030317 }
end.
