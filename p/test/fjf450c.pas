program fjf450c;

procedure foo (s : CString);
begin
  WriteLn (CString2String (s))
end;

var
  s : String (10) = 'xx';

begin
  foo (CString (s))  { WARN Frank, 20030317 }
end.
