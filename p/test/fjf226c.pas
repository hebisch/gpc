program fjf226c;
begin
  if False and_then (CString2String (CString(1)) = 'foo') then WriteLn ('foo') else WriteLn ('OK')
end.
