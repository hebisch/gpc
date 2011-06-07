program fjf574a;

var
  s: ^String = @'OK';

procedure p (a: CString);
begin
  WriteLn (Cstring2String (a))
end;

begin
  p (s^)
end.
