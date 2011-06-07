program fjf650;

procedure p (s: CString);
begin
  WriteLn (CString2String (s))
end;

procedure q (const s: String);
begin
  p (s)
end;

begin
  q ('OK')
end.
