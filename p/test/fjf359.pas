program fjf359;

type
  TString = String (2);

var
  s : TString = 'O';

procedure p (s : CString);
begin
  WriteLn ({$x+}s)
end;

begin
  p (s + 'K')
end.
