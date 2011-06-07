program fjf298a;

procedure x (var s : string);
begin
  writeln (s)
end;

begin
  x (CString2String ('failed')) { WRONG }
end.
