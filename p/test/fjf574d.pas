program fjf574d;

type
  TString = String (2);

var
  Called: Integer = 0;

function s: TString;
begin
  Inc (Called);
  s := 'OK'
end;

procedure p (a: CString);
begin
  if Called <> 1 then WriteLn ('failed ', Called) else WriteLn (Cstring2String (a))
end;

begin
  p (s)
end.
