program fjf450g;

procedure foo (...); external name 'foo';
procedure bar (s : CString); attribute (name = 'foo');
begin
  WriteLn (CString2String (s))
end;

var
  s : String (10) = 'xx';

begin
  foo (CString (s))  { WARN Frank, 20030317 }
end.
