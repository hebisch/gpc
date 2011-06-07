program fjf574b;

type
  PString = ^String;

var
  Called: Integer = 0;
  st: String (2) = 'OK';

function s: PString;
begin
  Inc (Called);
  s := @st
end;

procedure p (a: CString);
begin
  if Called <> 1 then WriteLn ('failed ', Called) else WriteLn (Cstring2String (a))
end;

begin
  p (s^)
end.
