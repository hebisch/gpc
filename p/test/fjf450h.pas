program fjf450h;

procedure foo (...); external name 'foo';
procedure bar (s : CString); attribute (name = 'foo');
begin
  WriteLn (CString2String (s))
end;

var
  s : String (10) = 'x';

begin
  foo (CString (s + 'y'))  { WRONG Frank, 20030317 }
end.
