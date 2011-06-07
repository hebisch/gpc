program fjf295a;
var s : string (10);
begin
  s := Copy (CString2String ('foo OK'), 5, 2);
  writeln (s)
end.
