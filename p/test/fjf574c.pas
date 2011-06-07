program fjf574c;

type
  TString = String (2);

var
  s: TString = 'OK';

procedure p (a: CString);
begin
  WriteLn (Cstring2String (a))
end;

begin
  p (s)
end.
